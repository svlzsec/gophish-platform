resource "aws_route53_record" "campaign" {
  zone_id = var.hosted_zone_id
  name    = var.campaign_domain
  type    = "A"
  ttl     = 60
  records = [aws_eip.gophish.public_ip]
}
