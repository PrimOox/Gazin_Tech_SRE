resource "local_file" "aws-auth-configmap" {
  depends_on = [module.eks_cluster]
  content    = module.eks_cluster.aws_auth_configmap_yaml
  filename   = "../k8s/aws-auth-configmap.yaml"
}