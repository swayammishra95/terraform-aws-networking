resource "aws_lb" "MyLB" {
  name               = var.name
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_groups
  subnets            = var.subnets
}

resource "aws_lb_target_group" "MyTG" {
  for_each = var.TargetGroups
  name     = each.value.name
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = var.vpc_id
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    interval = each.value.interval
    path = each.value.path
    protocol = each.value.protocol
    timeout = each.value.timeout
    healthy_threshold = each.value.healthy_thershold
    unhealthy_threshold = each.value.unhealthy_threshold
  }
}
resource "aws_lb_listener" "MyLG" {
  for_each = var.Listeners
  load_balancer_arn = aws_lb.MyLB.arn
  port              = each.value.listener_port
  protocol          = each.value.listener_protocol
  depends_on = [aws_lb_target_group.MyTG]
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
      type             = each.value.type
      target_group_arn = [for i in aws_lb_target_group.MyTG : i.arn][0]
    }
  }
