
# data source 
data "aws_availability_zones" "available" {
  state = "available"
}

# data source for ami 
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-*-x86_64"]
  }

  filter {
    name   = "name"
    values = ["Amazon Linux 2023 AMI*"]
  }
}

# VPC resource
resource "aws_vpc" "custom_main_vpc" {
  cidr_block = "10.0.0.0/16"

  enabled_dns_hostnames = true
  enabled_dns_support   = true

  tags = {
    Name = custom_main_vpc
  }

}

# Public subnet 
resource "aws_subnet" "public_subnet_234" {
  vpi_id                  = aws_vpc.custom_main_vpc.id
  cidr_block              = "10.0.156.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = public_subnet_234
  }

}

# internet gateway
resource "aws_internet_gateway" "custom_main_igw" {
  vpc_id = aws_vpc.custom_main_vpc.id

  tags = {
    Name = custom_main_igw
  }
}

# route table
resource "aws_route_table" "custom_main_rt" {
  vpc_id = aws_vpc.custom_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_main_igw.id
  }

  tags = {
    Name = "custom_main_rt"
  }
}

# route table association
resource "aws_main_route_table_association" "custom_main_rt_assoca" {
  subnet_id      = aws_subnet.public_subnet_234.id
  route_table_id = aws_route_table.custom_main_rt.id
}

resource "aws_security_group" "ecs_playwright_sg"{
name       = "ecs_playwright_sg"
description = "Allows Playwright outbound browsing while blocking all inbound traffic"
vpc_id = aws_vpc.custom_main_vpc.id

ingress {
}

#outbound allows playwright to browse the web/fastapi and pull images
egress{
protocol = "-1"
from_port = 0
to_port = 0 
cidr_blocks = ["0.0.0.0/0"]
}

}









