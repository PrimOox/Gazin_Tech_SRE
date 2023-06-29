variable "profile" {
  type        = string
  description = "Nome do profile configurado para o EC2"
}

variable "region" {
  type        = string
  description = "Região utilizada na AWS"
}

variable "aws_account" {
  type        = string
  description = "Numero da conta AWS"
}

variable "aws_username" {
  type        = string
  description = "Nome da conta (IAM) que possui a role para gerenciar as instâncias EC2"
}

variable "vpc_id" {
  type        = string
  description = "ID da VPC existente na AWS"
}
variable "subnet_ids" {
  type        = list(string)
  description = "IDs das sub-redes na VPC"
}
