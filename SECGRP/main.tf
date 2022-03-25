resource "aws_security_group" "MySG" {
  for_each = var.SecurityGroups
  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
      for_each = each.value.ingress 
      content {
        description      = ingress.value.description
        from_port        = ingress.value.from_port
        to_port          = ingress.value.to_port
        protocol         = ingress.value.protocol
        cidr_blocks      = ingress.value.cidr_blocks
      #   ipv6_cidr_blocks = 
      }
    }
  
  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  
  tags = {
    Name = "My  securitygroup"
  }
}