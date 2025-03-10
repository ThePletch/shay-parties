locals {
  application_env_vars = {
    RAILS_MASTER_KEY = data.local_sensitive_file.master_key.content
    DATABASE_USERNAME = var.database.username
    DATABASE_PASSWORD = var.database.password
    DATABASE_HOST = var.database.host
    DATABASE_NAME = "${var.database.cluster_name}.${var.database.database}"
    DATABASE_PORT = tostring(var.database.port)
    RACK_ENV = "production"
    RAILS_ENV = "production"
    # Eventually we'll want to move compiled assets into the
    # same object storage we use for image hosting.
    RAILS_SERVE_STATIC_FILES = "true"
    RAILS_LOG_TO_STDOUT = "true"
    ACTIVE_STORAGE_S3_BUCKET = var.activestorage.s3_bucket
    PARTIES_FULL_DOMAIN = local.main_domain
    PARTIES_BASE_DOMAIN = var.root_domain
    SES_SMTP_USERNAME = var.smtp.username
    SES_SMTP_PASSWORD = var.smtp.password
  }
  capacity_provider = "FARGATE_SPOT"
}
resource "aws_ecr_repository" "main" {
  name = "${var.name}-images"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
}

// default to spot instances for savings - use regular fargate if
// you care a lot about uptime
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [local.capacity_provider]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = local.capacity_provider
  }
}

resource "aws_ecs_service" "main" {
  cluster         = aws_ecs_cluster.main.id
  name            = "${var.name}-main"
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1

  network_configuration {
    subnets          = aws_subnet.public.*.id
    security_groups  = [aws_security_group.http.id]
    assign_public_ip = true
  }

  capacity_provider_strategy {
    base = 1
    capacity_provider = local.capacity_provider
    weight = 100
  }
}

resource "random_string" "secret_key_base" {
  special = false
  upper   = false
  length  = 50

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
  cpu                = 256
  memory             = 512
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.task_execution.arn
  task_role_arn      = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "rails"
      image     = "${aws_ecr_repository.main.repository_url}:latest"
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          hostPort      = var.internal_port
          containerPort = var.internal_port
        },
      ]
      environment = [
        for name, value in local.application_env_vars : {
          name = name
          value = value
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${var.name}-logs"
          awslogs-region        = "us-east-2"
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "parties"
        }
      }
    }
  ])
}
