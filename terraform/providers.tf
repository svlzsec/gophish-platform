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
