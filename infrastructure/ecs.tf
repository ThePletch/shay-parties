locals {
  # Non-sensitive application environment variables that can be embedded directly
  application_env_vars = {
    RACK_ENV                = var.environment
    RAILS_ENV               = var.environment
    # Eventually we'll want to move compiled assets into the
    # same object storage we use for image hosting.
    RAILS_SERVE_STATIC_FILES = "true"
    RAILS_LOG_TO_STDOUT      = "true"
    ACTIVE_STORAGE_S3_BUCKET = var.activestorage.s3_bucket
    PARTIES_FULL_DOMAIN      = local.main_domain
    PARTIES_BASE_DOMAIN      = var.root_domain
  }

  # Sensitive application environment variables stored in secured AWS SSM Parameters
  application_sensitive_env_vars = {
    RAILS_MASTER_KEY  = data.local_sensitive_file.master_key.content
    DATABASE_USERNAME = var.database.username
    DATABASE_PASSWORD = var.database.password
    DATABASE_HOST     = var.database.host
    DATABASE_NAME     = var.database.database
    DATABASE_PORT     = tostring(var.database.port)
    SES_SMTP_USERNAME = var.smtp.username
    SES_SMTP_PASSWORD = var.smtp.password
  }

  capacity_provider = "FARGATE_SPOT"
  # default domain is not listening for ipv6 requests, so we need to use the `on.aws` domain for dualstack support
  dualstack_registry_endpoint = replace(
    replace(
      aws_ecr_repository.main.repository_url,
      "amazonaws.com",
      "on.aws"
    ),
    "dkr.ecr",
    "dkr-ecr"
  )
}

resource "aws_ssm_parameter" "application" {
  for_each = local.application_sensitive_env_vars

  name = "/${var.environment}/${var.name}/${each.key}"
  type = "SecureString"
  value = each.value
}

resource "aws_ecr_repository" "main" {
  name = "${var.name}-images"
}

resource "aws_ecr_lifecycle_policy" "delete_older" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep most recent six images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 6
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
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
    subnets          = [for subnet in aws_subnet.public : subnet.id]
    security_groups  = [aws_security_group.http.id]
    assign_public_ip = true
  }

  service_connect_configuration {
    enabled = true
    namespace = aws_service_discovery_public_dns_namespace.public_ipv6.arn
  }

  service_registries {
    registry_arn = aws_service_discovery_service.public.arn
  }

  capacity_provider_strategy {
    base              = 1
    capacity_provider = local.capacity_provider
    weight            = 100
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
      image     = "${local.dualstack_registry_endpoint}:latest"
      essential = true
      portMappings = [
        {
          name = "http"
          protocol      = "tcp"
          hostPort      = var.internal_port
          containerPort = var.internal_port
        },
      ]
      environment = [
        for name, value in local.application_env_vars : {
          name  = name
          value = value
        }
      ]
      secrets = [
        for name, secret in aws_ssm_parameter.application : {
          name      = name
          valueFrom = secret.arn
        }
      ]
      healthCheck = {
        command = [ "CMD-SHELL", "curl -f http://localhost:${var.internal_port}/ || exit 1" ]
        startPeriod = 30
      }
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
