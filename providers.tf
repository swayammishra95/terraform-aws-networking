terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 1.1.3"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
