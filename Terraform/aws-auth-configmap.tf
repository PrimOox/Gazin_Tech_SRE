# # PowerShell
# resource "null_resource" "execute_script" {
#   depends_on = [module.eks_cluster]
#   provisioner "local-exec" {
#     command     = <<EOF
#     $ROLE_ARN = $(aws iam list-roles --query "Roles[?starts_with(RoleName,'mixed-1-node-group-')].Arn | [0]" --output text)
#     "$ROLE_ARN" | Set-Content -NoNewline -Path .\templates\node_group_role_arn.txt
#     $env:TF_VAR_node_group_role_arn = $ROLE_ARN
#     EOF
#     interpreter = ["PowerShell", "-Command"]
#   }
# }

# resource "local_file" "aws_auth" {
#   depends_on = [module.eks_cluster, null_resource.execute_script]
#   content = templatefile("${path.module}/templates/aws-auth-configmap.tpl", {
#     role_arn = file("/templates/node_group_role_arn.txt")
#   })
#   filename = "../k8s/aws-auth-configmap.yaml"
# }


# Bash
resource "null_resource" "execute_script" {
  depends_on = [module.eks_cluster]
  provisioner "local-exec" {
    command     = <<EOF
    ROLE_ARN=$(aws iam list-roles --query "Roles[?starts_with(RoleName,'mixed-1-node-group-')].Arn | [0]" --output text)
    echo "$ROLE_ARN" > templates/node_group_role_arn.txt
    export TF_VAR_node_group_role_arn=$ROLE_ARN
    EOF
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "local_file" "aws_auth" {
  depends_on = [null_resource.execute_script]
  content = templatefile("${path.module}/templates/aws-auth-configmap.tpl", {
    role_arn = file("/templates/node_group_role_arn.txt")
  })
  filename = "../k8s/aws-auth-configmap.yaml"
}
