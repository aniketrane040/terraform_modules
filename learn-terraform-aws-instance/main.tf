terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "arane_sg" {
  name = "arane_sg_group"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}
resource "aws_instance" "my_app" {
  ami           = "ami-0e731c8a588258d0d"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.arane_sg.id]

  tags = {
    user = var.tag
  }
}

