locals {
  github_oidc_url = "https://token.actions.githubusercontent.com"
}

# fetching the github OIDC thumbprint
data "tls_certificate" "github" {
  url = local.github_oidc_url
}

# # uncomment to set up initial OIDC - shared across all of your configs with GH access, so only do this once
# resource "aws_iam_openid_connect_provider" "github" {
#   url = local.github_oidc_url

#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = data.tls_certificate.github.certificates.*.sha1_fingerprint
# }

data "aws_iam_openid_connect_provider" "github" {
  url = local.github_oidc_url
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github.organization}/${var.github.repository}:*"]
    }
  }
}

data "aws_iam_policy_document" "ecs_logs" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_task_execution_secrets" {
  statement {
    actions = [
      # all read-only actions that can be scoped to individual params, e.g. GetParameterByPath
      "ssm:GetParameter*",
    ]
    resources = [for secret in aws_ssm_parameter.application : secret.arn]
  }

  statement {
    actions = [
      "ssm:DescribeParameters",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_deploy" {
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [aws_ecr_repository.main.arn]
  }

  # Token is scoped to permissions defined in the rest of this policy
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    actions = ["ecs:UpdateService"]
    # i hate that aws_ecs_service exposes the ARN but not under 'arn'
    resources = [aws_ecs_service.main.id]
  }

  statement {
    actions = ["ecs:RunTask"]
    # we need to wildcard this or we'd need to sync terraform to the
    # current revision during every single deploy
    resources = ["${aws_ecs_task_definition.main.arn_without_revision}:*"]
  }

  # required permission for running task definitions (avoids privilege escalation to ECS task's role permissions)
  statement {
    actions = ["iam:PassRole"]
    resources = [
      aws_ecs_task_definition.main.task_role_arn,
      aws_ecs_task_definition.main.execution_role_arn
    ]
  }
}

data "aws_iam_policy_document" "service_actions" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.activestorage.arn,
      "${aws_s3_bucket.activestorage.arn}/*",
    ]
  }
}

resource "aws_iam_role" "deploy" {
  name               = "${var.name}-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

resource "aws_iam_role_policy" "deploy" {
  role = aws_iam_role.deploy.name
  policy = data.aws_iam_policy_document.ecs_deploy.json
}

resource "aws_iam_role" "task_execution" {
  name               = "${var.name}-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy" "task_execution" {
  role = aws_iam_role.task_execution.name
  policy = data.aws_iam_policy_document.ecs_logs.json
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "task_execution_secrets" {
  role   = aws_iam_role.task_execution.name
  policy = data.aws_iam_policy_document.ecs_task_execution_secrets.json
}

resource "aws_iam_role" "task" {
  name               = "${var.name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy" "task" {
  role = aws_iam_role.task.name
  policy = data.aws_iam_policy_document.service_actions.json
}