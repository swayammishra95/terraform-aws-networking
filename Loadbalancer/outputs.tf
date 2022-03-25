output "lb_target_group_arn" {
    value = [for i in aws_lb_target_group.MyTG : i.arn][0]
}