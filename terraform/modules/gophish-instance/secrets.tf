# These are non-secret bootstrap markers. Operators overwrite them out-of-band
# Terraform
# ignores the values so real SecureString material is never read into configuration/state.
resource "aws_ssm_parameter" "runtime" {
  for_each = local.runtime_secret_names
  name     = "/gophish-platform/${var.client_name}/${each.value}"
  type     = "SecureString"
  value    = "PROVISION_EXTERNALLY"
  tags     = local.tags
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_iam_role" "instance" {
  name_prefix        = "${var.client_name}-gophish-instance-"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }] })
  tags               = local.tags
}
resource "aws_iam_role_policy" "runtime_secrets" {
  role = aws_iam_role.instance.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["ssm:GetParameter", "ssm:GetParameters"]
      Resource = concat(
        [for p in aws_ssm_parameter.runtime : p.arn],
        var.enable_ses ? [aws_ssm_parameter.mail_config[0].arn] : [],
      )
    }]
  })
}
resource "aws_iam_instance_profile" "this" {
  name_prefix = "${var.client_name}-gophish-"
  role        = aws_iam_role.instance.name
  tags        = local.tags
}
