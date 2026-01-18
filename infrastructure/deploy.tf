locals {
  plaintext_secrets = {
    AWS_ECR_REPOSITORY = aws_ecr_repository.main.name
    AWS_ECR_ROLE       = aws_iam_role.deploy.arn
    AWS_ECS_CLUSTER    = aws_ecs_cluster.main.name
    AWS_ECS_SERVICE    = aws_ecs_service.main.name
    AWS_REGION         = data.aws_region.current.name
    DATABASE_USERNAME  = var.database.username
    DATABASE_PASSWORD  = var.database.password
    DATABASE_HOST      = var.database.host
    DATABASE_PORT      = var.database.port
    DATABASE_NAME      = var.database.database
    RAILS_MASTER_KEY   = data.local_sensitive_file.master_key.content
  }
}

data "github_repository" "main" {
  full_name = "${var.github.organization}/${var.github.repository}"
}

# Pending work to modularize this to support multiple environments
resource "github_repository_environment" "deploy_env" {
  environment = var.environment
  repository  = data.github_repository.main.name
}

resource "github_actions_environment_secret" "deploy_secrets" {
  for_each        = local.plaintext_secrets
  repository      = data.github_repository.main.name
  environment     = github_repository_environment.deploy_env.environment
  secret_name     = each.key
  plaintext_value = each.value
}
