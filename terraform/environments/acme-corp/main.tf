terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0"
    }
    archive = { source = "hashicorp/archive", version = "~> 2.4"
    }
  }
}
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = { ManagedBy = "terraform"
    }
  }
}
variable "aws_region" {
  type = string
}
variable "client_name" {
  type = string
}
variable "campaign_name" {
  type = string
}
variable "campaign_domain" {
  type = string
}
variable "admin_allowlist_cidrs" {
  type = list(string)
}
variable "instance_size" {
  type = string
}
variable "scope_end" {
  type = string
}
variable "hosted_zone_id" {
  type = string
}
module "gophish" {
  source                = "../../modules/gophish-instance"
  client_name           = var.client_name
  campaign_name         = var.campaign_name
  campaign_domain       = var.campaign_domain
  admin_allowlist_cidrs = var.admin_allowlist_cidrs
  instance_size         = var.instance_size
  scope_end             = var.scope_end
  hosted_zone_id        = var.hosted_zone_id
}
output "landing_url" {
  value = module.gophish.landing_url
}
output "admin_url" {
  value = module.gophish.admin_url
}
