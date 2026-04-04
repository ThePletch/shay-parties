locals {
  environment_variables = {
    AWS_ECR_REPOSITORY = aws_ecr_repository.main.name
    AWS_ECR_ROLE       = aws_iam_role.deploy.arn
    AWS_ECS_CLUSTER    = aws_ecs_cluster.main.name
    AWS_ECS_SERVICE    = aws_ecs_service.main.name
    AWS_REGION         = data.aws_region.current.region
  }

  plaintext_secrets = {
    RAILS_MASTER_KEY   = data.local_sensitive_file.master_key.content
    DATABASE_USERNAME  = var.database.username
    DATABASE_PASSWORD  = var.database.password
    DATABASE_HOST      = var.database.host
    DATABASE_PORT      = var.database.port
    DATABASE_NAME      = var.database.database
  }
}

data "github_repository" "main" {
  full_name = "${var.github.organization}/${var.github.repository}"
}

resource "github_repository_environment" "deploy_env" {
  environment = var.environment
  repository  = data.github_repository.main.name
}

resource "github_actions_environment_variable" "deploy_variables" {
  for_each        = local.environment_variables
  repository      = data.github_repository.main.name
  environment     = github_repository_environment.deploy_env.environment
  variable_name   = each.key
  value           = each.value
}

resource "github_actions_environment_secret" "deploy_secrets" {
  for_each        = local.plaintext_secrets
  repository      = data.github_repository.main.name
  environment     = github_repository_environment.deploy_env.environment
  secret_name     = each.key
  plaintext_value = each.value
}
