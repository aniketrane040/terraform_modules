terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

variable "main_region" {
  type    = string
  default = "us-east-1"
}

provider "aws" {
  region = var.main_region
}

module "my_vpc" {
  source = "./modules/vpc"
  region = "us-east-1"
}

resource "aws_instance" "my_instance" {
  name = "ec2_instance"
  instance_type = "t2.micro"
  subnet_id = module.my_vpc.subnet_id
  vpc_security_group_ids = [module.my_vpc.sg_group_id]

  tags = {
    user = "arane"
  }
}