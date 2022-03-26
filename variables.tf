variable "aws_region" {
  default = "us-west-2"
}
variable "access_ip" {
  type = string
}
variable "username" {
  sensitive = true
}
variable "password" {
  sensitive = true
}

