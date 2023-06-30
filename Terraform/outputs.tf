output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server."
  value       = module.eks_cluster.cluster_endpoint
}

output "aws_auth_configmap_yaml" {
  description = "Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles."
  value       = module.eks_cluster.aws_auth_configmap_yaml
}
