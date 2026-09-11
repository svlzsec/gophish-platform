locals {
  tags = {
    Client          = var.client_name
    Campaign        = var.campaign_name
    AuthorizedUntil = var.scope_end
    ManagedBy       = "terraform"
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
