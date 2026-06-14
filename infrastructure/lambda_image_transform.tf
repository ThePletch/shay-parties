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

  # Deploy workflows push new :latest digests after Terraform creates the function.
  lifecycle {
    ignore_changes = [
      image_uri,
      image_config,
    ]
  }
}

data "aws_iam_policy_document" "ecs_task_lambda_invoke" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]

    resources = [
      aws_lambda_function.image_transform.arn,
    ]
  }
}

resource "aws_iam_role_policy" "task_lambda_invoke" {
  role   = aws_iam_role.task.name
  policy = data.aws_iam_policy_document.ecs_task_lambda_invoke.json
}
