output "vpc_id" {
    value = aws_vpc.MyVPC.id
}
output "default_route_table_id" {
    value = aws_vpc.MyVPC.default_route_table_id
}