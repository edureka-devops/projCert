# Configure the AWS Provider
provider "aws" {
    region = "ap-south-1"
    access_key = ""
    # XXX: no example found in the provider docs
    secret_key = ""
  
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc"
  }
}
#creating subnet mysubnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  depends_on = [aws_vpc.my_vpc]
  availability_zone = "ap-south-1a"

  tags = {
    Name = "my_subnet"
  }
}
#creating gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
  depends_on = [aws_vpc.my_vpc]
  tags = {
    Name = "my_gateway"
  }
}
#creating routetable
resource "aws_route_table" "my_route-table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_route-table"
  }
}
resource "aws_route" "my_route" {
  route_table_id            = aws_route_table.my_route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}
#root table association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route-table.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

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
resource "tls_private_key" "my_serverkey" {
  algorithm = "RSA"
}

resource "aws_key_pair" "app-instance-key" {

 key_name = "web-key"
 public_key = tls_private_key.my_serverkey.public_key_openssh
}

# save the key to local

resource local_file "web-key" {
 content = tls_private_key.my_serverkey.private_key_pem
 filename = "web-key.pem"

}


resource "aws_instance" "web" {
  ami           = "ami-0d81306eddc614a45"
  instance_type = "t2.micro"
  count = 1
  tags = {
    Name = "projetserver"
  }
  subnet_id = aws_subnet.my_subnet.id
  key_name = "web-key"
  security_groups = [aws_security_group.allow_web.id]

  provisioner "remote-exec" {
    connection {
     type = "ssh"
     user = "ec2-user"
     private_key = tls_private_key.my_serverkey.private_key_pem
     host = aws_instance.web[0].public_ip
    }
  inline = [
    "sudo yum install httpd php git -y",
    "sudo systemctl restart httpd",
    "sudo systemctl enable httpd"
  ]


}
