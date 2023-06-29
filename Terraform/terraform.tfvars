profile = "gazin"
region  = "us-east-2"

aws_account  = "376890117274"
aws_username = "primoox"

vpc_id     = "vpc-0a735912f23f28d16"
subnet_ids = ["subnet-05b8296075ec4c0f7", "subnet-02f26b89b67c4ca2d"]

# ROLE_ARN=$(aws iam list-roles --query "Roles[?starts_with(RoleName,'mixed-1-node-group-')].Arn | [0]" --output text)
# export TF_VAR_node_group_role_arn=$ROLE_ARN
# node_group_role_arn = "arn:aws:iam::376890117274:role/mixed-1-node-group-20230628165221007500000002"
