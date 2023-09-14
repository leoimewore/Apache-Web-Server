

resource "aws_launch_template" "first-template" {


  name          = "first-template"
  image_id      = "ami-051f7e7f6c2f40dc1"
  instance_type = "t2.micro"

  iam_instance_profile {
    name = var.profile
    
  }

  # Network interface configuration
  network_interfaces {
    security_groups = [aws_security_group.launch_ec2.id]
  }


  tag_specifications {
    
    resource_type = "instance"
    tags = {
      Name = "first template"
    }
 
  }
  user_data = filebase64("${path.module}/userdata.sh")
}


resource "aws_security_group" "launch_ec2" {
  vpc_id = var.vpc-id
  name = "private-subnet-traffic"
  


  ingress {
    from_port = "80"
    protocol = "TCP"
    to_port = "80"
    security_groups = [var.lb-sg]

  }
    


  egress{
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    to_port = 0
    protocol = -1
  }


  tags = {
    "Name" = "private-subnet-traffic"
  }
}


resource "aws_autoscaling_group" "private_asg" {
    name = "private_asg"
    max_size = 4
    min_size = 1
    desired_capacity = 2
    health_check_grace_period = 300
    health_check_type         = "ELB"
    vpc_zone_identifier = var.private_subnets
    launch_template {
      id = aws_launch_template.first-template.id
      version = "$Latest"
    }

     # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }

  
}

resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.private_asg.id
  lb_target_group_arn    = var.tg_arn
}

resource "aws_autoscaling_policy" "scale_up" {
  name = "scale_up"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.private_asg.name
  
}

resource "aws_autoscaling_policy" "scale_down" {
  name = "scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.private_asg.name
  
}



resource "aws_cloudwatch_metric_alarm" "project1-alarm_up" {
  alarm_name = "project1-alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period ="120"
  statistic = "Average"
  threshold = "80"

  dimensions = {
    AutoScalingGroupName =aws_autoscaling_group.private_asg.name
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]

  
}
resource "aws_cloudwatch_metric_alarm" "project1-alarm_down" {
  alarm_name = "project1-alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period ="120"
  statistic = "Average"
  threshold = "10"

  dimensions = {
    AutoScalingGroupName =aws_autoscaling_group.private_asg.name
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [aws_autoscaling_policy.scale_down.arn]

  
}



