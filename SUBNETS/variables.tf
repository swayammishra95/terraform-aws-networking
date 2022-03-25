variable "public_cidrs" {
    type = list
} 
variable "private_cidrs" {
    type = list
} 
variable "vpc_id" {}
variable "public_subnet_number" {
    type = number
}
variable "private_subnet_number" {
    type = number
}
variable "max_subnets" {
    type = number
}
variable "vpc_default_route_table_id" {}
