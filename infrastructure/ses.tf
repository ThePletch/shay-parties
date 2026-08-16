# SES lives in us-east-1 to match the SMTP endpoint used by Action Mailer.
# HTTPS SNS subscription is created after the app is serving /webhooks/ses
# (SNS must complete a SubscriptionConfirmation handshake).

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
