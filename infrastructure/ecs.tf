resource "aws_ecr_repository" "main" {
  name = "${var.name}-images"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_service" "main" {
  cluster         = aws_ecs_cluster.main.id
  name            = "${var.name}-main"
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1

  service_registries {
    registry_arn   = aws_service_discovery_service.main.arn
    container_name = "rails"
    container_port = 443
    port = 443
  }

  network_configuration {
    subnets = aws_subnet.public.*.id
    security_groups = [aws_security_group.http.id]
    assign_public_ip = true
  }
}

resource "random_string" "secret_key_base" {
  special = false
  upper = false
  length = 50

  keepers = {
    name = var.name
  }
}

resource "aws_ecs_task_definition" "main" {
  family = "${var.name}-main"

  # this is really low CPU! this is because this app is not doing anything complicated
  # (and fargate is expensive)
  # WATCH THIS SPACE if fargate adds support for burstable CPU:
  # https://github.com/aws/containers-roadmap/issues/163
  cpu          = 256
  memory       = 2048
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "rails"
      image     = "${aws_ecr_repository.main.repository_url}:latest"
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          hostPort      = 443
          containerPort = 443
        },
      ]
      environment = [
        {
          name  = "SECRET_KEY_BASE"
          value = random_string.secret_key_base.result
        },
        {
          name  = "DATABASE_USERNAME"
          value = var.database.username
        },
        {
          name  = "DATABASE_PASSWORD"
          value = var.database.password
        },
        {
          name  = "DATABASE_HOST"
          value = var.database.host
        },
        {
          name  = "DATABASE_NAME"
          value = var.database.database
        },
        {
          name  = "DATABASE_PORT"
          value = tostring(var.database.port)
        },
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group = "${var.name}-logs"
          awslogs-region = "us-east-2"
          awslogs-create-group = "true"
          awslogs-stream-prefix = "parties"
        }
      }
    }
  ])
}