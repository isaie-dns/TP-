# providers.tf
terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "terraform_isaie_dns"
      Module      = "tp03-web-ec2"
      ManagedBy   = "isaie_dns"
      Environment = var.environment
      Owner       = "etudiant06"
      Etudiant    = "etudiant06"
    }
  }
}
