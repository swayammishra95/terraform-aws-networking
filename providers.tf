terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
  
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  access_key = var.my-access-key
  secret_key = var.my-secret-key
}
