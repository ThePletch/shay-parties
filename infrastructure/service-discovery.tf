locals {
  service_discovery_service_name = "sdtest"
}

data "aws_iam_policy_document" "discovery_hook_policy" {
  statement {
    actions = [
      "ec2:DescribeNetworkInterfaces",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      data.aws_route53_zone.root_domain.arn,
    ]
  }
}

module "service_discovery_lambda" {
  source = "git@github.com:ThePletch/infrastructure.git//modules/lambda-function"

  name                      = "${var.name}-dns-handler"
  source_code_file          = "./lambda/service-discovery.py"
  function_runtime          = "python3.9"
  iam_policy                = data.aws_iam_policy_document.discovery_hook_policy.json
  include_inline_policy     = true
  publish                   = true
  error_notifications_email = var.errors_email
  environment_config = {
    HOSTED_ZONE_ID   = data.aws_route53_zone.root_domain.zone_id
    ROOT_DOMAIN      = var.root_domain
    TARGET_SUBDOMAIN = local.service_discovery_service_name
  }
}

resource "aws_cloudwatch_event_rule" "task_start_stop" {
  name        = "${var.name}-dns-mgr"
  description = "Manage DNS for Parties for All"
  # Applies to all state change events for this cluster. Will do weird things if other services go in this cluster,
  # including other services for this app.
  event_pattern = jsonencode({
    "detail-type" = ["ECS Task State Change"]
    detail = {
      clusterArn = [aws_ecs_cluster.main.arn]
    }
  })
}

resource "aws_lambda_permission" "event_invoke_lambda" {
  statement_id  = "${var.name}-invoke-dns-handler"
  action        = "lambda:InvokeFunction"
  function_name = module.service_discovery_lambda.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.task_start_stop.arn
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.task_start_stop.name
  arn  = module.service_discovery_lambda.arn
}