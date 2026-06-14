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
  value = aws_lambda_function.image_transform.function_name
}
