# SES lives in us-east-1 to match the SMTP endpoint used by Action Mailer.
# The HTTPS SNS subscription is gated on bootstrap.ses_webhook_subscription so the
# first apply can provision the topic before /webhooks/ses is serving.

data "aws_caller_identity" "current" {}

resource "aws_sesv2_configuration_set" "invites" {
  provider               = aws.northern_virginia
  configuration_set_name = "${var.name}-invites"
}

resource "aws_sns_topic" "ses_events" {
  provider = aws.northern_virginia
  name     = "${var.name}-ses-events"
}

data "aws_iam_policy_document" "ses_events_topic" {
  statement {
    sid     = "AllowSESPublish"
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    resources = [aws_sns_topic.ses_events.arn]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_sns_topic_policy" "ses_events" {
  provider = aws.northern_virginia
  arn      = aws_sns_topic.ses_events.arn
  policy   = data.aws_iam_policy_document.ses_events_topic.json
}

resource "aws_sesv2_configuration_set_event_destination" "sns" {
  provider               = aws.northern_virginia
  configuration_set_name = aws_sesv2_configuration_set.invites.configuration_set_name
  event_destination_name = "sns-bounce-complaint"

  event_destination {
    enabled              = true
    matching_event_types = ["BOUNCE", "COMPLAINT"]

    sns_destination {
      topic_arn = aws_sns_topic.ses_events.arn
    }
  }
}

resource "aws_sns_topic_subscription" "ses_webhooks" {
  count = var.bootstrap.ses_webhook_subscription ? 1 : 0

  provider  = aws.northern_virginia
  topic_arn = aws_sns_topic.ses_events.arn
  protocol  = "https"
  endpoint  = "https://${local.main_domain}/webhooks/ses"

  # SNS retries confirmation until the app confirms via SubscribeURL.
  confirmation_timeout_in_minutes = 5
}

check "ses_webhook_subscription_bootstrap" {
  assert {
    condition     = var.bootstrap.ses_webhook_subscription
    error_message = <<-EOT
      SES bounce/complaint webhooks are not subscribed. Bootstrap steps:
        1. Run the deploy workflow for this environment (app must serve POST /webhooks/ses).
        2. Re-run Terraform with bootstrap.ses_webhook_subscription = true
           (e.g. terraform apply -var='bootstrap={ses_webhook_subscription=true}' or set it in your tfvars).
      Until then, bounce and complaint notifications are published to SNS but not delivered to the app.
    EOT
  }
}
