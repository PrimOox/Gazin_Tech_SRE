provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  backend "s3" {
    profile = "gazin"
    bucket  = "teste-sre-gazin-tech"
    key     = "deploy/s3/terraform.tfstate"
    encrypt = true
    region  = "us-east-2"
  }

  required_providers {
    aws = "~> 5.5.0"
  }
}

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = "k8s-cluster"
  cluster_version = "1.27"

  cluster_endpoint_public_access = true

  vpc_id     = var.vpc_id                           # ID da VPC existente na AWS
  subnet_ids = [var.subnet_ids.0, var.subnet_ids.1] # IDs das sub-redes na VPC

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                          = "t2.medium"
    update_launch_template_default_version = true
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  self_managed_node_groups = {
    one = {
      name         = "mixed-1"
      max_size     = 4
      desired_size = 2

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 10
          spot_allocation_strategy                 = "capacity-optimized"
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

}
