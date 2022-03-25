output "RDS_SG_IDs" {
    value = aws_security_group.MySG["RDS"].*.id
}
output "LB_SG_IDs" {
    value = aws_security_group.MySG["Public"].*.id
}