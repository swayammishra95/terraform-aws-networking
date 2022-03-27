module "VPC" {
  source   = "./VPC"
  vpc_cidr = local.vpc_cidr
}

module "SUBNETS" {
  source                     = "./SUBNETS"
  public_subnet_number       = 3
  private_subnet_number      = 3
  max_subnets                = module.SUBNETS.max_subnets_number
  public_cidrs               = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs              = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  vpc_id                     = module.VPC.vpc_id                 #output of vpc
  vpc_default_route_table_id = module.VPC.default_route_table_id #output of vpc
}

module "SECGRP" {
  source        = "./SECGRP"
  vpc_id        = module.VPC.vpc_id
  SecurityGroups = local.SecurityGroups
}

module "DB_RDS" {
  source = "./DB_RDS"
  rds_subnet_group = module.SUBNETS.db_subnet_group_name
  RDS_SG_IDs = module.SECGRP.RDS_SG_IDs
  allocated_storage    = local.allocated_storage
  engine               = local.engine
  engine_version       = local.engine_version
  instance_class       = local.instance_class
  name                 = local.name
  username             = var.username
  password             = var.password
  parameter_group_name = local.parameter_group_name
  skip_final_snapshot  = local.skip_final_snapshot
}

module "Loadbalancer" {
  source = "./Loadbalancer"
  name = local.dbname
  load_balancer_type = local.load_balancer_type
  security_groups = module.SECGRP.LB_SG_IDs
  subnets = module.SUBNETS.lb_subnets
  vpc_id = module.VPC.vpc_id
  TargetGroups = local.TargetGroups
  Listeners = local.Listeners
  # target_group_arns = module.Loadbalancer.target_group_arns
}

# module "Compute" {
#   source = "./Compute"
#   instance_count = 3
#   volume_size = 10
#   instance_type = "t2.micro"
#   public_sg = module.SECGRP.LB_SG_IDs
#   public_subnets = module.SUBNETS.lb_subnets
#   lb_target_group_arn = module.Loadbalancer.lb_target_group_arn
#   key_name = "Mykey"
#   public_key_path = "/home/ubuntu/.ssh/mykey.pub"
#   user_data_path = "${path.root}/userdata.tpl"
# }

module "COMPUTE-A" {
  source = "./COMPUTE-A"
  key_name                  = "Mykey"
  #   public_key_path           = "/home/ubuntu/.ssh/mykey.pub"
  public_key_path           = "/home/ec2-user/.ssh/mykey"
  instance_type             = "t2.micro"
  ebs_volume_size           = 8
  public_sg                 = module.SECGRP.LB_SG_IDs
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_nodes             = 2
  public_subnets            = module.SUBNETS.lb_subnets
  lb_target_group_arn       = module.Loadbalancer.lb_target_group_arn
  user_data_path            = "${path.root}/userdata.tpl"
}
