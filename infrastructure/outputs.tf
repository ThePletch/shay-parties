output "ses_configuration_set_name" {
  value = aws_sesv2_configuration_set.invites.configuration_set_name
}

output "ses_events_sns_topic_arn" {
  value = aws_sns_topic.ses_events.arn
}

output "ses_webhook_subscription_arn" {
  value       = try(aws_sns_topic_subscription.ses_webhooks[0].arn, null)
  description = "Null until bootstrap.ses_webhook_subscription is true and Terraform has been applied after the app is serving /webhooks/ses."
}

output "ses_webhook_subscription_bootstrap_pending" {
  value       = !var.bootstrap.ses_webhook_subscription
  description = "True when the environment is not fully set up. Deploy the app, then apply with bootstrap.ses_webhook_subscription = true."
}

output "ses_webhook_subscription_bootstrap_instructions" {
  value = var.bootstrap.ses_webhook_subscription ? null : <<-EOT
    Environment bootstrap incomplete: SES SNS webhook subscription is not created yet.
    1. Run the GitHub deploy workflow for this environment.
    2. terraform apply -var='bootstrap={ses_webhook_subscription=true}'
       (or set bootstrap.ses_webhook_subscription = true in your tfvars and apply).
  EOT
  description = "Follow these steps after the first apply on a new environment. Null once bootstrap is complete."
}

output "ecr_repository_url" {
  value = aws_ecr_repository.main.repository_url
}

output "ecr_image_transform_repository_url" {
  value = aws_ecr_repository.image_transform_lambda.repository_url
}

output "image_transform_lambda_function_name" {
  value       = try(aws_lambda_function.image_transform[0].function_name, null)
  description = "Null until bootstrap.image_transform_lambda is true and Terraform has been applied again after the first deploy."
}

output "image_transform_lambda_bootstrap_pending" {
  value       = !var.bootstrap.image_transform_lambda
  description = "True when the environment is not fully set up. Run deploy, then apply with bootstrap.image_transform_lambda = true."
}

output "image_transform_lambda_bootstrap_instructions" {
  value = var.bootstrap.image_transform_lambda ? null : <<-EOT
    Environment bootstrap incomplete: image transform Lambda is not created yet.
    1. Run the GitHub deploy workflow for this environment.
    2. terraform apply -var='bootstrap={image_transform_lambda=true}'
       (or set bootstrap.image_transform_lambda = true in your tfvars and apply).
  EOT
  description = "Follow these steps after the first apply on a new environment. Null once bootstrap is complete."
}
