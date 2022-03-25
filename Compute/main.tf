data "aws_ami" "server_ami" {
    most_recent = true
    owners = ["137112412989"]
    
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-*"]
    }
}

resource "random_id" "My_node_id" {
    byte_length = 2
    count = var.instance_count
    keepers = {
        key_name = var.key_name
        user_data = var.user_data
    }
}

resource "aws_key_pair" "My_auth" {
  key_name   = "var.key_name"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "My_node" {
    count = var.instance_count
    instance_type = var.instance_type
    ami = data.aws_ami.server_ami.id
    tags = {
        Name = "My_node-${random_id.My_node_id[count.index].dec}"
    }
key_name = aws_key_pair.My_auth.id
vpc_security_group_ids = var.public_sg
subnet_id = var.public_subnets[count.index]
user_data = templatefile(var.user_data_path,{nodename = "My_node-${random_id.My_node_id[count.index].dec}"})
root_block_device {
    volume_size = var.volume_size
}
}

resource "aws_lb_target_group_attachment" "Myattachment" {
  count = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_instance.My_node[count.index].id
  port             = 80
}

