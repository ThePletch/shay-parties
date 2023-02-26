resource "aws_ecr_repository" "main" {
  name = "${var.name}-images"
}

resource "aws_ecs_capacity_provider" "asg" {
  name = "${var.name}-asg"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_runners.arn
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [aws_ecs_capacity_provider.asg.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.asg.name
  }
}

resource "aws_ecs_service" "main" {
  cluster         = aws_ecs_cluster.main.id
  name            = "${var.name}-main"
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 0

  capacity_provider_strategy {
    base              = 1
    capacity_provider = aws_ecs_capacity_provider.asg.name
    weight            = 100
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.main.arn
    container_name = "rails"
    container_port = 3000
  }
}

resource "aws_ecs_task_definition" "main" {
  family = "${var.name}-main"

  cpu          = 512
  memory       = 1024
  network_mode = "bridge"

  container_definitions = jsonencode([
    {
      name      = "rails"
      image     = "${aws_ecr_repository.main.repository_url}:latest"
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          hostPort      = 0
          containerPort = 3000
        },
      ]
      environment = [
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
    }
  ])
}