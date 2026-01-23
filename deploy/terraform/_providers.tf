provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Team      = "mfa"
      Project   = var.project_name
      Terraform = "true"
    }
  }
}

provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.ecr_auth.proxy_endpoint
    username = data.aws_ecr_authorization_token.ecr_auth.user_name
    password = data.aws_ecr_authorization_token.ecr_auth.password
  }
}
