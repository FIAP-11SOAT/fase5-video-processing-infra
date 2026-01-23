data "aws_ecr_authorization_token" "ecr_auth" {}

locals {
  clean_image_repo_url = replace(data.aws_ecr_authorization_token.ecr_auth.proxy_endpoint, "https://", "")
}

resource "aws_ecr_repository" "lambda_image" {
  name = "default-lambda-image"
}

resource "null_resource" "pull_tag_push_image" {

  provisioner "local-exec" {
    command = <<-EOT
      # Authenticate Docker to ECR
      aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${local.clean_image_repo_url}

      # Pull an existing image from Docker Hub
      docker pull tecinforibeiro/default-lambda-image:latest

      # Tag the pulled image for ECR
      docker tag tecinforibeiro/default-lambda-image:latest ${local.clean_image_repo_url}/${aws_ecr_repository.lambda_image.name}:latest

      # Push the tagged image to the ECR repository
      docker push ${local.clean_image_repo_url}/${aws_ecr_repository.lambda_image.name}:latest
    EOT
  }

  depends_on = [aws_ecr_repository.lambda_image]
}