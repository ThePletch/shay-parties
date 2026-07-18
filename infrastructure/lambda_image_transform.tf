data "aws_iam_policy_document" "image_transform_lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "image_transform_lambda" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.activestorage.arn,
      "${aws_s3_bucket.activestorage.arn}/*",
    ]
  }
}

resource "aws_iam_role" "image_transform_lambda" {
  name               = "${var.name}-image-transform"
  assume_role_policy = data.aws_iam_policy_document.image_transform_lambda_assume_role.json
}

resource "aws_iam_role_policy" "image_transform_lambda" {
  role   = aws_iam_role.image_transform_lambda.name
  policy = data.aws_iam_policy_document.image_transform_lambda.json
}

resource "aws_ecr_repository" "image_transform_lambda" {
  name = "${var.name}-image-transform"
}

resource "aws_lambda_function" "image_transform" {
  count = var.create_image_transform_lambda ? 1 : 0

  function_name = "${var.name}-image-transform"
  role          = aws_iam_role.image_transform_lambda.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.image_transform_lambda.repository_url}:latest"
  timeout       = 60
  memory_size   = 1024
  architectures = ["arm64"]

  image_config {
    command = ["handler.lambda_handler"]
  }

  # Deploy workflow owns image updates via UpdateFunctionCode after each ECR push.
  lifecycle {
    ignore_changes = [
      image_uri,
      image_config,
    ]
  }
}

data "aws_iam_policy_document" "ecs_task_lambda_invoke" {
  count = var.create_image_transform_lambda ? 1 : 0

  statement {
    actions = [
      "lambda:InvokeFunction",
    ]

    resources = [
      aws_lambda_function.image_transform[0].arn,
    ]
  }
}

resource "aws_iam_role_policy" "task_lambda_invoke" {
  count = var.create_image_transform_lambda ? 1 : 0

  role   = aws_iam_role.task.name
  policy = data.aws_iam_policy_document.ecs_task_lambda_invoke[0].json
}

check "image_transform_lambda_bootstrap" {
  assert {
    condition = var.create_image_transform_lambda
    error_message = <<-EOT
      Image transform Lambda is not provisioned. Bootstrap steps:
        1. Run the deploy workflow for this environment (builds and pushes the Lambda image to ECR).
        2. Re-run Terraform with create_image_transform_lambda = true
           (e.g. terraform apply -var='create_image_transform_lambda=true' or set it in your tfvars).
      Until then, Active Storage image transforms run locally in the Rails container instead of Lambda.
    EOT
  }
}
