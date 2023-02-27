locals {
  github_oidc_url = "https://token.actions.githubusercontent.com"
}

# fetching the github OIDC thumbprint
data "tls_certificate" "github" {
  url = local.github_oidc_url
}

resource "aws_iam_openid_connect_provider" "github" {
  url = local.github_oidc_url

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.github.certificates.*.sha1_fingerprint
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
      identifiers = [aws_iam_openid_connect_provider.github.arn]
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
}

resource "aws_iam_role" "deploy" {
  name               = "${var.name}-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json

  inline_policy {
    name   = "deploy"
    policy = data.aws_iam_policy_document.ecs_deploy.json
  }
}

resource "aws_iam_role" "task_execution" {
  name               = "${var.name}-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  inline_policy {
    name   = "logs"
    policy = data.aws_iam_policy_document.ecs_logs.json
  }
}

resource "aws_iam_role" "task" {
  name               = "${var.name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}