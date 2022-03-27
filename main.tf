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
  public_key_path           = '''-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEA1q+kM2pr3Z/yraCAFR/ClAJwLDLD3WM6uMbCYrwEcA5ayRva
LKas144MLnQoXFtexPoyGFCXglw1Q8ap0biERdQhSqI93Pfv25W5QwwqVUrxmmNq
l9ljtXZITZspSE+p/eXBy9Kj9b1LxH0WdiVU6tIXoxQOOCIrM+09FwuIM8V4G/N4
P7tMQMSVfLKLiF302chQ3D16/kuN7NHFPfXJ5TXFZ0xXwhXwj7ZB7C6adlFtqYnu
udPZAoWl0GKfuzbgJyvHEzRb7aQXDUWiWTVv4GsnpfzzW38vH6c/Xv3LwelcVc9k
LkuY+bzQKmRM0oIRYi0CgXznlp9vwE4RYabGIQIDAQABAoIBAQDQRac7hiPM5u4M
iSeY1q3y3wapqjof3bNLLO/Jz3NSrmperhmTtcL6f0DMFD5Pkwi2ea79rbm+auv1
q5Z18dbI04nUmN8BLrtQQMlxBS1Qf5sx1v7C/8/ebDiqqTt8fmSA/1NqBBiyPwlx
PpT62y6tfFIYEE3XITbecmoQoExrQ4CGtPJ0a7WPAm7tc9VcqOvTv2Ya1U7z18ZB
3Ch4a9PEBzLyB8nnpbn/1Ze0DocS+4AqSzZJoHcY3lN17m4u9wvra+Vvwt9kTo1t
aBiBNhAsK0qCgeLg7IvlHe14hj3lHGKtiMVRKMKGuUAUis+Sb+/l02iwqbpvwOCS
DTUeMTSdAoGBAPmUoEQ42MRmknBpjSfw/SLQnjPeb5/g8vZy7DogAYALmc8Et6P5
NV3r4v7W7jm2D0ZpJnLwE/CMREjaldc9MZjByfhkZhlNoO5QsN1xW8b6RJJ0M8ud
EuW3hoHHp24Lpuh+Dacu7xS8x2xJ9Dy6wz7sF38Kb74lvACFQE7zyejTAoGBANw1
QFB38J6TLkaPPDtmpgWPX9wAxBWhhk7bHVAeXBcuakzDrkAngEwCUxKY8/FO0WD/
Bm7hO6zhc2YhpyCDgf7p0Wbp4Y33y0O22nW/awGfKXFhMzgrLDOwcb46w/xIGQlz
hg3j0N3/pvR5A4toLSuwbTVVtd4Dz0O3eyun3vy7AoGBAI/NjB5i5rsbIqs0lgl6
eFAUBeN6+bQUB8nqY6QGBvdBN+kpHaqUD6TDInKVYoPMG7cFJQs6uzJxj3Kux4FS
F/6dQgMlzhIsQVqvEYk2JJxcXSBJZgKeyWGkwhKK+DSW8B+rabB3gXfgYcNKRTis
n4zkuZEQcVwNH+ro3Cnhm+fTAoGAZ88WvZh9L1Q0+YBmpZ4TYAWh7AXUaloWBbCX
1gAp66eu5vdMeuPkQHDMFrVSMoy0eeRfdP/q8OnrS9dLgTFdo/04ASr6cMHC6e4W
eHG/kSkmEVQAIFeB4/Am/sWXRKP8YY87P+sIuM7fNtqhiCOZP8JRCVaZgMsM92BU
yVS+8ycCgYEAj1WgmSCDvxdW8TBdOnjxHEl4m/R8qnV0qRKAzMXazJSMrBv7oGkh
HOyErF4SpOImVGsg3IJ9mGs4R+yMI6dgNO9nbH5eyK7dUZ72UlGEXsw+3Ind/b6W
75o4IXmco7AJ+aGkQk4H1QJXSpMNiQ59P4uiwEidrp0bDKEobwaDTkU=
-----END RSA PRIVATE KEY----'''
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
