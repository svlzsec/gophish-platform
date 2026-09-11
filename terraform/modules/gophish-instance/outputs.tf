output "landing_ip" {
  value = aws_eip.gophish.public_ip
}
output "landing_url" {
  value = "https://${aws_route53_record.campaign.fqdn}"
}
output "admin_url" {
  value = "https://${aws_route53_record.campaign.fqdn}:3333"
}
output "instance_arn" {
  value = aws_instance.gophish.arn
}
output "shutdown_lambda_arn" {
  value = aws_lambda_function.shutdown.arn
}
output "shutdown_schedule_arn" {
  value = aws_scheduler_schedule.shutdown.arn
}
