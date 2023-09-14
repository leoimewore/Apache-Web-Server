output "alb_arn" {
    value = data.aws_lb.lb_arn.arn
  
}

output "tg_arn" {
    value = data.aws_lb_target_group.target_group_arn.arn
  
}

output "lb-sg" {
    value = aws_security_group.al_eg1.id
  
}

output "alb_hosted_zone" {
    value = data.aws_lb_hosted_zone_id.main.id
  
}

output "alb_name" {
    value = data.aws_lb.lb_arn.name
}

output "dns_name"{
    value =data.aws_lb.lb_arn.dns_name
}