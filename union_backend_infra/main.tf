terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
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