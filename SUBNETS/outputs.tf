output "max_subnets_number" {
    value = var.private_subnet_number + var.public_subnet_number
}

output "db_subnet_group_name" {
    value = aws_db_subnet_group.My_rds_subnetgroup.name
}

output "lb_subnets" {
    value = aws_subnet.MyVPC_public_subnet.*.id
}