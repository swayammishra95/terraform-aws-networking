data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "aws_subnet" "MyVPC_public_subnet" {
  count = var.public_subnet_number
  vpc_id     = var.vpc_id
  cidr_block = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "MyVPC_public_subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "MyVPC_private_subnet" {
  count = var.private_subnet_number
  vpc_id     = var.vpc_id
  cidr_block = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "MyVPC_private_subnet_${count.index + 1}"
  }
}
resource "aws_internet_gateway" "MyIg" {
  vpc_id = var.vpc_id

  tags = {
    Name = "MyIg"
  }
}
resource "aws_route_table" "MyPublicRoutetable" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyIg.id
  }
  tags = {
    Name = "MyPublicRoutetable"
  }
}
resource "aws_default_route_table" "MyPrivateRoutetable" {
  default_route_table_id = var.vpc_default_route_table_id

  tags = {
    Name = "MyPrivateRoutetable"
  }
}
resource "aws_route_table_association" "MyPublicSubnetAssoc" {
  count = var.public_subnet_number
  subnet_id      = [for o in aws_subnet.MyVPC_public_subnet : o.id][count.index]
  # subnet_id      = aws_subnet.MyVPC_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.MyPublicRoutetable.id
}

resource "aws_db_subnet_group" "My_rds_subnetgroup" {
  name       = "rds_sg"
  subnet_ids = aws_subnet.MyVPC_private_subnet.*.id

  tags = {
    Name = "My DB subnet group"
  }
}