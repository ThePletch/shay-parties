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
  cluster = aws_ecs_cluster.main.id
  name = "${var.name}-main"
  task_definition = aws_ecs_task_definition.main.arn

  service_registries {
    registry_arn = aws_service_discovery_service.main.arn
  }
}

resource "aws_ecs_task_definition" "main" {
  family = "${var.name}-main"

  cpu = 512
  memory = 1024

  container_definitions = jsonencode([
    {
      name = "rails"
      image = "${aws_ecr_repository.main.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 80
        },
      ]
    }
  ])
}