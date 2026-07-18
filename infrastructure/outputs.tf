output "aws_region" {
  value = data.aws_region.current.region
}

output "ecr_repository_url" {
  value = aws_ecr_repository.main.repository_url
}

output "ecr_image_transform_repository_url" {
  value = aws_ecr_repository.image_transform_lambda.repository_url
}

output "image_transform_lambda_function_name" {
  value       = try(aws_lambda_function.image_transform[0].function_name, null)
  description = "Null until create_image_transform_lambda is true and Terraform has been applied again after the first deploy."
}

output "image_transform_lambda_bootstrap_pending" {
  value       = !var.create_image_transform_lambda
  description = "True when the environment is not fully set up. Run deploy, then apply with create_image_transform_lambda = true."
}

output "image_transform_lambda_bootstrap_instructions" {
  value = var.create_image_transform_lambda ? null : <<-EOT
    Environment bootstrap incomplete: image transform Lambda is not created yet.
    1. Run the GitHub deploy workflow for this environment.
    2. terraform apply -var='create_image_transform_lambda=true'
       (or add create_image_transform_lambda = true to your tfvars and apply).
  EOT
  description = "Follow these steps after the first apply on a new environment. Null once bootstrap is complete."
}
