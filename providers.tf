terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  access_key = "var.AWS_ACCESS_KEY"
  secret_key = "var.AWS_SECRET_KEY"
  region = var.aws_region
}
