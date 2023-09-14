resource "aws_security_group" "al_eg1" {
  vpc_id = var.vpc-id
  name = "lb-traffic"
  

   ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 80
    protocol = "TCP"
    to_port = 80
  }


  egress{
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    to_port = 0
    protocol = -1
  }


  tags = {
    "Name" = "lb-traffic"
  }
}






resource "aws_lb" "public" {

  
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.al_eg1.id]
  subnets= var.public_subnets
  

  enable_deletion_protection = false

 depends_on = [var.public_subnets ]


  tags = {
    Environment = "production"
  }
  
}


resource "aws_lb_target_group" "tg_group" {
  name       = "my-app-eg1"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc-id
  slow_start = 0

  load_balancing_algorithm_type = "round_robin"

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

   health_check {
    enabled             = true
    port                = 80
    interval            = 300
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

data "aws_lb" "lb_arn" {
  arn  = aws_lb.public.arn
  name = aws_lb.public.name
  
  
}

data "aws_lb_target_group" "target_group_arn" {
  arn  = aws_lb_target_group.tg_group.arn
  name = aws_lb_target_group.tg_group.name
}


resource "aws_lb_listener" "web" {
    load_balancer_arn = aws_lb.public.arn
    port = "80"
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.tg_group.arn
    }
  
}

data "aws_lb_hosted_zone_id" "main" {}



