output "vpc_id" {
    value = aws_vpc.main.id
}


output "public_subnets" {
 value = [for s in data.aws_subnet.example : s.id]
  
}

output "private_subnets" {
    value =[for s in data.aws_subnet.private : s.id]
}

