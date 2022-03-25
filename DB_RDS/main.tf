resource "aws_db_instance" "MY_RDS" {
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  name                 = var.name
  username             = var.username
  password             = var.password
  parameter_group_name = var.parameter_group_name
  skip_final_snapshot  = var.skip_final_snapshot
  db_subnet_group_name = var.rds_subnet_group
  vpc_security_group_ids = var.RDS_SG_IDs
  tags = {
    Name = "My_rds_db" 
  }
}