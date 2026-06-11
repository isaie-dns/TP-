# envs/dev/main.tf

module "vpc" {
  source = "../../modules/vpc"

  environment          = "dev"
  project_name         = "formation_isaie"
  vpc_cidr             = "10.10.0.0/16"
  azs                  = ["eu-west-3a", "eu-west-3b"]
  bastion_allowed_cidr = "0.0.0.0/0"
}