variable "vpc-id" {
    description = "vpc identification number"
  
}

variable "private_subnets" {
    description = "list of private subnet to locate asg"
  
}

variable "lb-arn" {
    description = "load balancer arn"
  
}

variable "profile" {
    description = "instance profile for launch config"
  
}

variable "tg_arn" {
    description = "target group arn for the lb and asg connection"
  
}

variable "lb-sg" {
    description = "security group of load balancer"
  
}
