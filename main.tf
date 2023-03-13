provider "aws" {
  region = "us-east-1"
}

# Create a VPC to enable me build a virtual network for my resources in the AWS cloud 
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "my-vpc"
  }
}

# create public and private subnets to specify a range of IP addresses in my VPC
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private-subnet"
  }
}

// create an internet gateway enables resources in my public subnets 
// to connect to the internet if the resource has a public IPv4 address 

resource "aws_internet_gateway" "my-ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "my-gateway"
  }
}

// create a route table to contain a set of rules, called routes, that determine where network traffic 
// from subnet or gateway is directed.
resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-ig.id
  }

  tags = {
    Name = "route-table"
  }
}

// associate route table with existing public subnet and route table
resource "aws_route_table_association" "associate" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.my-rt.id
}

// create security group to set inbound and outbound rules on ports HTTP HTTPS and SSH 
resource "aws_security_group" "my_sg" {
  name   = "HTTP, HTTPS and SSH"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  description = "Allow HTTPS"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// create an ec2 instance
resource "aws_instance" "web_instance" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  associate_public_ip_address = true

  user_data = file("bash.sh")

  tags = {
    "Name" : "my-ubuntu-server"
  }
}