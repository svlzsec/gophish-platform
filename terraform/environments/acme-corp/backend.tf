terraform {
  backend "s3" {
    bucket         = "gophish-platform-terraform-state"
    key            = "clients/acme-corp/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "gophish-platform-terraform-locks"
    encrypt        = true
  }
}
