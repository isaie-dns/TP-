# envs/dev/providers.tf


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
      Project     = "formation-terraform_isaie"
      Module      = "tp04-multi-env"
      owner       = "etudiant06"
      ManagedBy   = "Terraform"
      Environment = "staging"
    }
  }
}