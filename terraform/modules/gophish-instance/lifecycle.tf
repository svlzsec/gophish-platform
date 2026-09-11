data "archive_file" "shutdown" {
  type        = "zip"
  output_path = "${path.root}/.terraform/${var.client_name}-shutdown.zip"
  source {
    filename = "lambda_function.py"
    content  = <<-PY
import boto3
def handler(event, context):
    boto3.client("ec2").terminate_instances(InstanceIds=[event["instance_id"]])
    return {"terminated": event["instance_id"]}
PY
  }
}
resource "aws_iam_role" "shutdown" {
  name_prefix        = "${var.client_name}-shutdown-"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }] })
  tags               = local.tags
}
resource "aws_iam_role_policy" "shutdown" {
  role   = aws_iam_role.shutdown.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = "ec2:TerminateInstances", Resource = "*", Condition = { StringEquals = { "ec2:ResourceTag/Client" = var.client_name, "ec2:ResourceTag/Campaign" = var.campaign_name } } }, { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" }] })
}
resource "aws_lambda_function" "shutdown" {
  function_name    = "${var.client_name}-gophish-authorized-shutdown"
  role             = aws_iam_role.shutdown.arn
  handler          = "lambda_function.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.shutdown.output_path
  source_code_hash = data.archive_file.shutdown.output_base64sha256
  tags             = local.tags
}
resource "aws_iam_role" "scheduler" {
  name_prefix        = "${var.client_name}-scheduler-"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "scheduler.amazonaws.com" }, Action = "sts:AssumeRole" }] })
  tags               = local.tags
}
resource "aws_iam_role_policy" "scheduler" {
  role   = aws_iam_role.scheduler.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = "lambda:InvokeFunction", Resource = aws_lambda_function.shutdown.arn }] })
}
resource "aws_scheduler_schedule" "shutdown" {
  name                         = "${var.client_name}-gophish-scope-end"
  schedule_expression          = "at(${formatdate("YYYY-MM-DD'T'hh:mm:ss", var.scope_end)})"
  schedule_expression_timezone = "UTC"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_lambda_function.shutdown.arn
    role_arn = aws_iam_role.scheduler.arn
    input    = jsonencode({ instance_id = aws_instance.gophish.id })
  }
}
