resource "aws_vpc" "union_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "union_subnet" {
  vpc_id            = aws_vpc.union_vpc.id
  cidr_block        = "10.0.0.0/16"
}

resource "aws_security_group" "union_sg" {
  name        = "union_sg"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.union_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }
}

resource "aws_ecs_cluster" "union_cluster" {
  name = "union_cluster"
}

resource "aws_ecs_task_definition" "union_task_defination" {
  family                   = "union_app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"

  container_definitions = jsonencode([
    {
      name      = "union_backend_container"
      image     = "public.ecr.aws/m7p9x7q8/union-backend-app:latest"
      cpu       = 512
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "CONNECTION_URL"
          value = "mongodb+srv://tempActions:6UP1U0aMV5J9yH8X@cluster0.j8fs6vi.mongodb.net/?retryWrites=true&w=majority"
        },
        {
          name  = "PORT"
          value = "3000"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "union_service" {
  name            = "union_service"
  cluster         = aws_ecs_cluster.union_cluster.id
  task_definition = aws_ecs_task_definition.union_task_defination.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.union_subnet.id]
    security_groups  = [aws_security_group.union_sg.id]
    assign_public_ip = true
  }
}