


# Configure the AWS Provider
provider "aws" {
  version = "~> 4.0"
  region = var.aws_region
  access_key = var.my-access-key
  secret_key = var.my-secret-key
}
