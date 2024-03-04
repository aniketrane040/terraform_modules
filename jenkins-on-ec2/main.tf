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

data "aws_ssm_parameter" "vpc-id" {
  name = var.parameter_for_vpc
}

data "aws_vpc" "selected" {
  id = data.aws_ssm_parameter.vpc-id.value
}

resource "aws_security_group" "jenkins_sg" {
  name   = "jenkins_sg_group"
  vpc_id = data.aws_vpc.selected.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access_cidr]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.web_access_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  #   key_name      = var.key_name

  subnet_id = var.subnet-id

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = file("${path.module}/jenkins_install_script.sh")

  tags = {
    name = "jenkins"
    user = "arane"
  }
}

