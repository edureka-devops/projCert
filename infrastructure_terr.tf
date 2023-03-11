# Configure the AWS Provider
provider "aws" {
    region = "ap-south-1"
    access_key = ""
    # XXX: no example found in the provider docs
    secret_key = ""
  
}

# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc"
  }
}
resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  depends_on = [aws.vpc.myvpc]
  availability_zone = "ap-south-1a"

  tags = {
    Name = "my_subnet"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my_gateway"
  }
}
resource "aws_route_table" "myroutetable" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "my_routetable"
  }
}
#root table association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myroutetable.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}
resource "aws_instance" "php_web" {
  ami           = "ami-0d81306eddc614a45" 
  instance_type = "t2.micro"
  tags = {
    Name = "php_web"
  }
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}





