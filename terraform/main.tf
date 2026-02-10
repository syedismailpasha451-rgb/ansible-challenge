provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "frontend" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 (check region)
  instance_type = "t3.micro"
  key_name      = "Ansible"

  tags = {
    Name = "c8.local"
  }
}

resource "aws_instance" "backend" {
  ami           = "ami-053b0d53c279acc90" # Ubuntu (update if needed)
  instance_type = "t3.micro"
  key_name      = "Ansible"

  tags = {
    Name = "u21.local"
  }
}

