# variables.tf
variable "aws_region" {
  type        = string
  description = "Region AWS de deploiement"
  default     = "eu-west-3"
}

variable "environment" {
  type        = string
  description = "Environnement de deploiement"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment doit etre dev, staging ou prod."
  }
}

variable "project_name" {
  type        = string
  description = "tp03"
  default     = "tp03"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR du VPC (doit etre un /16 ou /20)"
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr doit etre un CIDR valide (ex: 10.0.0.0/16)."
  }
}

variable "azs" {
  type        = list(string)
  description = "Liste des AZ a utiliser (minimum 2)"
  default     = ["eu-west-3a", "eu-west-3b"]

  validation {
    condition     = length(var.azs) >= 2
    error_message = "Au moins 2 AZ requises pour la HA."
  }
}

variable "bastion_allowed_cidr" {
  type        = string
  description = "CIDR autorise a se connecter en SSH au bastion"
}

variable "instance_type" {
  type        = string
  description = "Type d'instance EC2 pour bastion et web"
  default     = "t3.micro"
}

variable "public_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Chemin vers la cle SSH locale"
}
