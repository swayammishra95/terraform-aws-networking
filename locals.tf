locals {
  vpc_cidr = "10.124.0.0/16"
}
locals {
  SecurityGroups = {
    Public = {
      name        = "PublicSG"
      description = "Security Group for public access."
      ingress = {
        ssh = {
          description = "ssh access"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        http = {
          description = "http access"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
      }
    }
    RDS = {
      name        = "RDS_SG"
      description = "Security Group for rds."
      ingress = {
        ssh = {
          description = "rds access"
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      } 
    }
  }
}

locals {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

locals {
  dbname = "My-LoadBalancer"
  load_balancer_type = "application"
}

locals {
  TargetGroups = {
    FirstTG = {
      name     = "First-TG"
      port     = 80
      protocol = "HTTP"
      interval = 10
      path = "/"
      protocol = "HTTP"
      timeout = 5
      healthy_thershold = 5
      unhealthy_threshold = 2
    }
    # SecondTG = {
    #   name     = "Second-TG"
    #   port     = 80
    #   protocol = "HTTP"
    #   interval = 10
    #   path = "/"
    #   protocol = "HTTP"
    #   timeout = 5
    #   healthy_thershold = 5
    #   unhealthy_threshold = 2
    #   }
    }
  }
  
  locals {
    Listeners = {
      FirstL = {
        listener_port = "80"
        listener_protocol = "HTTP"
        type = "forward"
      }
      #   SecondL = {
      #   listener_port = "8000"
      #   listener_protocol = "HTTP"
      #   type = "forward"
      # }
    }
  }
