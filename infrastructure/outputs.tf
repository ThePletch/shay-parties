output "ses_configuration_set_name" {
  value = aws_sesv2_configuration_set.invites.configuration_set_name
}

output "ses_events_sns_topic_arn" {
  value = aws_sns_topic.ses_events.arn
}

output "ses_webhook_subscribe_command" {
  value = <<-EOT
    After the app is deployed, subscribe SNS to the webhook:
    aws sns subscribe --region us-east-1 --topic-arn ${aws_sns_topic.ses_events.arn} --protocol https --notification-endpoint https://${local.main_domain}/webhooks/ses
  EOT
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
