[![CI/CD Pipeline](https://github.com/PrimOox/Gazin_Tech_SRE/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/PrimOox/Gazin_Tech_SRE/actions/workflows/ci-cd.yml)
# Projeto Teste - Gazin SRE

Este projeto demonstra como configurar e implementar uma aplicação simples em um cluster Kubernetes na AWS (EKS) usando Terraform e Helm.

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

    Se as instâncias EC2 não estiverem sendo autorizadas de forma automática para se juntar ao cluster, você precisas configurar o ConfigMap "aws-auth" manualmente.

    ```bash
    kubectl apply -f k8s/aws-auth-configmap.yaml --kubeconfig=kubeconfig.yaml
    ```

4. **Instalar o repositório do Helm que contém o chart do NGINX que iremos utilizar**

    ```bash
    helm repo add bitnami https://charts.bitnami.com/bitnami
    ```

    Atualize a lista de charts disponíveis:

    ```bash
    helm repo update
    ```

5. **implementar a Aplicação NGINX com uma estratégia de HPA**

    implementar a aplicação NGINX já com HPA configurado usando o Helm chart.

    ```bash
    helm upgrade --install my-web-app bitnami/nginx --set autoscaling.enabled=true --set autoscaling.minReplicas=2 --set autoscaling.maxReplicas=5 --set autoscaling.targetCPU=50 --set autoscaling.targetMemory=80 --set resources.requests.cpu=100m --set resources.requests.memory=128Mi --set resources.limits.cpu=200m --set resources.limits.memory=256Mi --kubeconfig=kubeconfig.yaml
    ```

6. **Verificar a Implantação**

    Verifique se a implantação foi bem-sucedida verificando os recursos do Helm, os serviços e os pods.

    ```bash
    helm list --kubeconfig=kubeconfig.yaml
    kubectl get nodes --kubeconfig=kubeconfig.yaml
    kubectl get configmap --kubeconfig=kubeconfig.yaml
    kubectl get svc --kubeconfig=kubeconfig.yaml
    kubectl get pods --kubeconfig=kubeconfig.yaml
    kubectl get hpa --kubeconfig=kubeconfig.yaml
    ```

7. **Testar a Aplicação**

    Faça uma requisição HTTP para o endereço IP externo do serviço para testar a aplicação, ou acesse através do browser (pode levar alguns minutos para ficar disponível).

    ```bash
    curl http://<external-ip>
    ```

    Substitua `<external-ip>` pelo endereço IP externo do seu serviço.

8. **Limpeza**

    Após terminar de testar a aplicação, você pode limpar os recursos criados com os seguintes comandos:

    ```bash
    helm uninstall my-web-app --kubeconfig=kubeconfig.yaml
    terraform destroy
    ```

## Problemas Conhecidos

- Se o pod não estiver subindo, tenta configurar o ConfigMap novamente (etapa 3).
- Se o HPA não estiver conseguindo acessar as métricas de utilização de CPU e memória será necessário instalar o servidor de métricas manualmente com um chart do Helm:

    ```bash
    helm repo update
    helm upgrade --install metrics-server bitnami/metrics-server --namespace kube-system --kubeconfig=kubeconfig.yaml
    helm upgrade --install --namespace kube-system metrics-server oci://registry-1.docker.io/bitnamicharts/metrics-server --set apiService.create=true --kubeconfig=kubeconfig.yaml

    # Lista as métricas
    kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" --kubeconfig=kubeconfig.yaml
    kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods" --kubeconfig=kubeconfig.yaml
    # PowerShell
    kubectl get pods --all-namespaces --kubeconfig=kubeconfig.yaml | findstr metrics-server
    #Bash
    kubectl get pods --all-namespaces --kubeconfig=kubeconfig.yaml | grep metrics-server
    ```