resource "aws_ses_domain_identity" "this" {
  count  = var.enable_ses ? 1 : 0
  domain = var.mail_domain
}

resource "aws_route53_record" "ses_verification" {
  count   = var.enable_ses ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = "_amazonses.${var.mail_domain}"
  type    = "TXT"
  ttl     = 300
  records = [aws_ses_domain_identity.this[0].verification_token]
}

resource "aws_ses_domain_dkim" "this" {
  count  = var.enable_ses ? 1 : 0
  domain = aws_ses_domain_identity.this[0].domain
}

resource "aws_route53_record" "ses_dkim" {
  for_each = var.enable_ses ? toset(aws_ses_domain_dkim.this[0].dkim_tokens) : toset([])
  zone_id  = var.hosted_zone_id
  name     = "${each.value}._domainkey.${var.mail_domain}"
  type     = "CNAME"
  ttl      = 300
  records  = ["${each.value}.dkim.amazonses.com"]
}

resource "aws_ssm_parameter" "mail_config" {
  count = var.enable_ses ? 1 : 0
  name  = "/gophish-platform/${var.client_name}/mail-config"
  type  = "String"
  value = jsonencode({
    provider = "ses"
    host     = local.mail_smtp_host
    port     = var.mail_smtp_port
    from     = var.mail_from
    tls      = true
  })
  tags = local.tags
}

output "mail_smtp_host" {
  value = var.enable_ses ? local.mail_smtp_host : null
}

output "mail_verification_token" {
  value     = var.enable_ses ? aws_ses_domain_identity.this[0].verification_token : null
  sensitive = true
}