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
  region = var.region
}

data "aws_ssm_parameter" "vpc-id" {
  name = var.parameter_for_vpc
}

data "aws_vpc" "selected" {
  id = data.aws_ssm_parameter.vpc-id.value
}

resource "aws_subnet" "selected" {
  vpc_id     = data.aws_vpc.selected.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "my_sg" {
  name   = "sg_group"
  vpc_id = data.aws_vpc.selected.id
}