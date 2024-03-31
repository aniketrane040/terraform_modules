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

resource "aws_security_group" "union_sg" {
  name = "union_sg_group"
  vpc_id = data.aws_vpc.selected.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "union_task_def" {
  family = "union_task_def"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsondecode([
    {
        name = "union_backend_container"
        image = "public.ecr.aws/m7p9x7q8/union-backend-app:latest"
        cpu = "512"
        memory = "512"
        portMappings = [
            {
                container_port = 3000
                host_port = 3000
            }
        ]
        environment = [
            {
                name = "CONNECTION_URL"
                value = ""
            },
            {
                name = "PORT"
                value = "3000"
            }
        ]
    }
  ])
}

resource "aws_ecs_cluster" "union_cluster" {
  name = "union_cluster"
}

resource "aws_ecs_service" "union_service" {
  name = "union_service"
  cluster = aws_ecs_cluster.union_cluster.id
  task_definition = aws_ecs_task_definition.union_task_def.arn
  desired_count = 1
  launch_type = "FARGATE"
  
  depends_on = [ aws_ecs_cluster.union_cluster ]
}