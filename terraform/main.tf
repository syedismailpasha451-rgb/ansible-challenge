provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

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

resource "aws_instance" "frontend" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2023
  instance_type          = "t3.micro"
  key_name               = "Ansible"
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  tags = {
    Name = "c8.local"
  }
}

resource "aws_instance" "backend" {
  ami                    = "ami-053b0d53c279acc90" # Ubuntu 22
  instance_type          = "t3.micro"
  key_name               = "Ansible"
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  tags = {
    Name = "u21.local"
  }
}
