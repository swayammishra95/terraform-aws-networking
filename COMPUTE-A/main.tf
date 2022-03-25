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
    count = var.max_size
    keepers = {
        key_name = var.key_name
        user_data = var.user_data_path
    }
}

resource "aws_key_pair" "My_auth" {
  key_name   = "var.key_name"
  public_key = file(var.public_key_path)
}

resource "aws_launch_template" "ec2-launch-template" {
  name                   = "ASG-launch-template"
  image_id               = data.aws_ami.server_ami.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.My_auth.id
  vpc_security_group_ids = var.public_sg

  tags = {
    Name = "aws-ec2-launch-template"
  }

  user_data = filebase64(var.user_data_path)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "MyASG" {
  name                      = "frontend-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  desired_capacity          = var.desired_nodes
  force_delete              = true
  vpc_zone_identifier       = var.public_subnets
  target_group_arns         = [var.lb_target_group_arn]

  launch_template {
    id      = aws_launch_template.ec2-launch-template.id
    version = "$Latest"
  }
  #-- Automatically refresh all instances after the group is updated--
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
  tags = [{
    "key"                 = "Name"
    "value"               = "asg-instances"
    "propagate_at_launch" = true
  }]
}