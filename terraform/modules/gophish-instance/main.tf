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

locals {
  runtime_secret_names = setunion(var.secret_names, var.enable_ses ? ["smtp-user", "smtp-password"] : [])
  mail_smtp_host       = "email-smtp.${data.aws_region.current.name}.amazonaws.com"
}
