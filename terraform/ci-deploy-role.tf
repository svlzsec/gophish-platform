variable "github_repository" {
  type        = string
  description = "GitHub owner/repository allowed to deploy"
}
variable "github_oidc_provider_arn" {
  type = string
}

resource "aws_iam_role" "ci_deployer" {
  name = "gophish-platform-ci-deployer"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Federated = var.github_oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = { "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:environment:production"
        }
      }
    }]
  })
  tags = { Client = "shared", Campaign = "platform", AuthorizedUntil = "managed-per-campaign", ManagedBy = "terraform"
  }
}

# Scope to platform resources. Account-level guardrails/SCPs should additionally constrain region and account.
resource "aws_iam_role_policy" "ci_deployer" {
  role = aws_iam_role.ci_deployer.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["ec2:*", "iam:*", "lambda:*", "scheduler:*", "route53:*", "ssm:*", "logs:*"], Resource = "*" },
    { Effect = "Allow", Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"], Resource = "arn:aws:s3:::gophish-platform-terraform-state/clients/*" },
    { Effect = "Allow", Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:DescribeTable"], Resource = "arn:aws:dynamodb:*:*:table/gophish-platform-terraform-locks"
    }
  ] })
}
