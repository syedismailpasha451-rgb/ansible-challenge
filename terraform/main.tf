provider "aws" {
  region = "us-east-1"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group
resource "aws_security_group" "allow_web" {
  name        = "allow-web-ssh"
  description = "Allow SSH, HTTP, Netdata"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 19999
    to_port     = 19999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Frontend EC2
resource "aws_instance" "frontend" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  key_name      = "Ansible"

  subnet_id              = "subnet-0b9fac4f91fd48a0c"
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  tags = {
    Name = "c8.local"
  }
}

# Backend EC2
resource "aws_instance" "backend" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t3.micro"
  key_name      = "Ansible"

  subnet_id              = "subnet-0b9fac4f91fd48a0c"
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  tags = {
    Name = "u21.local"
  }
}
