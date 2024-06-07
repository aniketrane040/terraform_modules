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

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id
}

resource "aws_security_group" "union_sg" {
  name   = "union_sg_group"
  vpc_id = data.aws_vpc.selected.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
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

resource "aws_lb" "union_alb" {
  name               = "union-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.union_sg.id]
  subnets            = data.aws_subnet_ids.selected.ids
  tags = {
    Environment = "development"
  }
}

resource "aws_lb_target_group" "union_tg" {
  name        = "union-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.selected.id
  target_type = "ip"
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
  }
}

resource "aws_lb_listener" "union_listener" {
  load_balancer_arn = aws_lb.union_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.union_tg.arn
  }
}

resource "aws_ecs_task_definition" "union_task_def" {
  family                   = "union_task_def"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"

  container_definitions = jsonencode([
    {
      name   = "union_backend_container"
      image  = "public.ecr.aws/m7p9x7q8/union-backend-app:latest"
      cpu    = 512
      memory = 512
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name  = "CONNECTION_URL"
          value = ""
        },
        {
          name  = "PORT"
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
  name            = "union_service"
  cluster         = aws_ecs_cluster.union_cluster.id
  task_definition = aws_ecs_task_definition.union_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  depends_on = [aws_ecs_cluster.union_cluster]

  load_balancer {
    target_group_arn = aws_lb_target_group.union_tg.arn
    container_name   = "union_backend_container"
    container_port   = 3000
  }

  network_configuration {
    assign_public_ip = true # Set to "DISABLED" if not needed
    subnets         = data.aws_subnet_ids.selected.ids # List your subnet IDs
    security_groups = [aws_security_group.union_sg.id]  # List your SG IDs
  }
}
