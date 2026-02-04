terraform {
  backend "s3" {
    bucket = "fase5-terraform-state"
    key    = "fase5-video-processing-infra/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }
  }
}
