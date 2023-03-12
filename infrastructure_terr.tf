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
#creating subnet mysubnet
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
#creating gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id
  depends_on = [aws.vpc.myvpc]
  tags = {
    Name = "my_gateway"
  }
}
#creating routetable
resource "aws_route_table" "myroutetable" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "my_routetable"
  }
}
resource "aws_route" "myroute" {
  route_table_id            = "aws_route_table.myroutetable.id"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
  depends_on                = [aws_route_table.testing]
}
#root table association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myroutetable.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
    ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
    ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}
# RSA key of size 4096 bits
resource "tls_private_key" "myserverkey" {
  algorithm = "RSA"
}

resource "aws_key_pair" "app-instance-key" {

 key_name = "web-key"
 public_key = tls_private_key.web-key.public_key_openssh
}

# save the key to local

resource local_file "web-key" {

 content = tls_private_key.web-key.private_key_pem
 filename = "web-key.pem"
}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  count = 1
  tags = {
    Name = "${var.environment}-${count.index}"
  }
  subnet_id = aws_subnet.subnet-1.id
  key_name = "web-key"
  security_groups = [aws_security_group.allow_web.id]

  provisioner "remote-exec" {
    connection {
     type = "ssh"
     user = "ec2-user"
     private_key = tls_private_key.web-key.private_key_pem
     host = aws_instance.web[0].public_ip
    }
  inline = [
    "sudo yum install httpd php git -y",
    "sudo systemctl restart httpd",
    "sudo systemctl enable httpd"
  ]


}
}




