data "github_repository" "main" {
  full_name = "${var.github.organization}/${var.github.repository}"
}

# Pending work to modularize this to support multiple environments
resource "github_repository_environment" "deploy-test" {
  environment = "deploy-test"
  repository = data.github_repository.main.name
}