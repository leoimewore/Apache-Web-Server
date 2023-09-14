//Create Virtual private Cloud with a 3 subnets: 1 Public and two private subnets

resource "aws_vpc" "main" {
  cidr_block = var.vpc-CIDR
  tags = {
    Name = "main"
  }

  enable_dns_hostnames = true
  enable_dns_support = true
}


resource "aws_subnet" "main-subnet" {
  for_each = var.prefix
 
  availability_zone_id = each.value["az"]
  cidr_block = each.value["cidr"]
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "Public-subnet-${each.key}"
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "tag:Name"
    values = ["Public-subnet-*"]
  }
}

data "aws_subnet" "example" {
  for_each = toset(data.aws_subnets.selected.ids)
  id       = each.value
}

resource "aws_subnet" "private-subnet" {
  for_each = var.suffix
 
  availability_zone_id = each.value["az"]
  cidr_block = each.value["cidr"]
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "Private-subnet-${each.key}"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["Private-subnet-*"]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
  depends_on = [ aws_vpc.main ]
}

resource "aws_internet_gateway" "Igw" {
  vpc_id =aws_vpc.main.id 

  tags = {
    Name="Igw"
  } 
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
  }

  tags = {
    Name = "PublicRT"
  }
}

resource "aws_route_table_association" "route1" {
  count ="${length(data.aws_subnet.example)}"
  subnet_id = "${element([for s in data.aws_subnet.example : s.id],count.index)}"
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table" "PrivateRT1" {
  vpc_id = aws_vpc.main.id


  
  depends_on = [ aws_subnet.main-subnet ]

  tags = {
    Name = "PrivateRT1"
  }
}


resource "aws_route_table" "PrivateRT2" {
  vpc_id = aws_vpc.main.id 
  

  depends_on=[aws_subnet.main-subnet] 

  tags = {
    Name = "PrivateRT2"
  }
}


resource "aws_vpc_endpoint" "ec2-message" {
  vpc_id = aws_vpc.main.id
  vpc_endpoint_type = "Interface"
  service_name = "com.amazonaws.us-east-1.ec2messages"
  security_group_ids = [aws_security_group.ssm-ec2.id]
  subnet_ids = [for s in data.aws_subnet.private : s.id]

  private_dns_enabled = true
  
}

resource "aws_vpc_endpoint" "ssm-message" {
  vpc_id = aws_vpc.main.id
  vpc_endpoint_type = "Interface"
  service_name = "com.amazonaws.us-east-1.ssmmessages"
  security_group_ids = [aws_security_group.ssm-ec2.id]
  subnet_ids = [for s in data.aws_subnet.private : s.id]

  private_dns_enabled = true
  
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id = aws_vpc.main.id
  vpc_endpoint_type = "Interface"
  service_name = "com.amazonaws.us-east-1.ssm"
  security_group_ids = [aws_security_group.ssm-ec2.id]
  subnet_ids = [for s in data.aws_subnet.private : s.id]

  private_dns_enabled = true
  
}





resource "aws_security_group" "ssm-ec2" {
  vpc_id = aws_vpc.main.id
  name = "ssm-ec2-traffic"
  

   ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = "443"
    to_port = "443"
    protocol = "TCP"
  }
    


  egress{
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    to_port = 0
    protocol = -1
  }


  tags = {
    "Name" = "ssm-ec2-traffic"
  }
}

resource "aws_eip" "ip" {
  domain     = "vpc"
  count ="${length(data.aws_subnet.private)}"
  tags = {
    Name = "t4-elasticIP"
  }
}

//Start from here???


resource "aws_nat_gateway" "privatengw" {

  count ="${length(data.aws_subnet.example)}"
  allocation_id = "${element(aws_eip.ip.*.id, count.index)}"
  subnet_id = "${element([for s in data.aws_subnet.example : s.id],count.index)}"

  tags = {
    Name = "gw NAT-${count.index}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_subnet.main-subnet]
}


resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.main.id
  count ="${length(data.aws_subnet.private)}"
 


  route {
    
    cidr_block = "0.0.0.0/0"
    gateway_id= "${element(aws_nat_gateway.privatengw.*.id,count.index)}"
  }

  tags = {
    Name = "PrivateRT${count.index}"
  }
}

data "aws_route_tables" "rts" {
  vpc_id = aws_vpc.main.id

  filter {
   name   = "tag:Name"
    values = ["PrivateRT*"]
  }
}

resource "aws_route_table_association" "route2" {
  count ="${length(data.aws_subnet.private)}"
  subnet_id = "${element([for s in data.aws_subnet.private : s.id],count.index)}"
  route_table_id = "${element(aws_route_table.rt2.*.id, count.index)}"
}

resource "aws_vpc_endpoint" "s3" {
  count = length(data.aws_route_tables.rts.*.ids)
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.us-east-1.s3"
  route_table_ids = tolist(data.aws_route_tables.rts.*.ids)[count.index]

  tags = {
    Name = "my-s3-endpoint"
  }
}








