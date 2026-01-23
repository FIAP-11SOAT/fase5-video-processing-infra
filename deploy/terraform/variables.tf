data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

data "aws_secretsmanager_secret" "master_secrets" {
  name = "terraform-master-credentials"
}

data "aws_secretsmanager_secret_version" "master_secrets" {
  secret_id = data.aws_secretsmanager_secret.master_secrets.id
}

locals {
  aws_master_secrets = jsondecode(data.aws_secretsmanager_secret_version.master_secrets.secret_string)
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "fase5-video-processing-infra"
}
