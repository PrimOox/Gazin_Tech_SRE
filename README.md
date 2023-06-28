# Projeto Teste - Gazin SRE

Este projeto demonstra como configurar e implantar uma aplicação simples em um cluster Kubernetes na AWS (EKS) usando Terraform e Helm.

## Pré-requisitos

- [AWS CLI](https://aws.amazon.com/cli/) instalado e configurado com o seu perfil AWS.
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) instalado.
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) instalado.
- [Helm](https://helm.sh/docs/intro/install/) instalado.

## Instruções

1. **Configurar o Cluster EKS na AWS**

    Execute o script do Terraform para criar o cluster EKS na AWS.

    ```bash
    terraform init
    terraform apply
    ```

2. **Configurar o Kubeconfig**

    Atualize o arquivo kubeconfig com as informações do seu cluster EKS. Esta etapa é necessária para que o kubectl possa interagir com o cluster. Para fazer isso, você pode usar o comando `aws eks update-kubeconfig`:

    ```bash
    aws eks --region us-east-2 update-kubeconfig --name k8s-cluster --profile gazin --kubeconfig kubeconfig.yaml
    ```

    Isso irá gerar um arquivo kubeconfig.yaml no diretório atual.

3. **Configurar o ConfigMap "aws-auth"**

    Se as instâncias EC2 não estiverem sendo autorizadas de forma automática para se juntar ao cluster, você pode precisar configurar o ConfigMap "aws-auth".

    ```bash
    kubectl apply -f k8s/aws-auth-configmap.yaml --kubeconfig=kubeconfig.yaml
    ```

4. **Instalar o repositório do Helm que contém os charts que iremos utilizar**

    ```bash
    helm repo add bitnami https://charts.bitnami.com/bitnami
    ```

    Atualize a lista de charts disponíveis:

    ```bash
    helm repo update
    ```

5. **Implantar a Aplicação**

    Implantar a aplicação nginx usando o Helm chart.

    ```bash
    helm install my-web-app bitnami/nginx --kubeconfig=kubeconfig.yaml
    ```

6. **Configurar o Horizontal Pod Autoscaler (HPA)**

    Configure o HPA para a aplicação.

    ```bash
    kubectl apply -f k8s/nginx-hpa.yaml --kubeconfig=kubeconfig.yaml
    ```

7. **Verificar a Implantação**

    Verifique se a implantação foi bem-sucedida verificando os recursos do Helm, os serviços e os pods.

    ```bash
    helm list --kubeconfig=kubeconfig.yaml
    kubectl get svc --kubeconfig=kubeconfig.yaml
    kubectl get pods --kubeconfig=kubeconfig.yaml
    ```

8. **Testar a Aplicação**

    Faça uma requisição HTTP para o endereço IP externo do serviço para testar a aplicação.

    ```bash
    curl http://<external-ip>
    ```

    Substitua `<external-ip>` pelo endereço IP externo do seu serviço.

9. **Limpeza**

    Após terminar de testar a aplicação, você pode limpar os recursos criados com os seguintes comandos:

    ```bash
    helm uninstall my-web-app --kubeconfig=kubeconfig.yaml
    terraform destroy
    ```

## Problemas Conhecidos

- HPA não está conseguindo acessar as métricas de CPU em utilização. Você pode tentar instalar o servidor de métricas manualmente para tentar solucionar este problema:

    ```bash
    helm repo update
    helm install metrics-server bitnami/metrics-server --namespace kube-system --kubeconfig=kubeconfig.yaml
    helm upgrade --namespace kube-system metrics-server oci://registry-1.docker.io/bitnamicharts/metrics-server --set apiService.create=true --kubeconfig=kubeconfig.yaml
    # Lista as métricas
    kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" --kubeconfig=kubeconfig.yaml
    ```