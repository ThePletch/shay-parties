resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]
  # per https://github.blog/changelog/2022-01-13-github-actions-update-on-oidc-based-deployments-to-aws/
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = aws_iam_openid_connect_provider.github.arn
    }

    condition {
      test = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = ["sts.amazonaws.com"]
    }

    condition {
      test = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = ["repo:${var.github.organization}/${var.github.repository}:ref:refs/heads/${var.github.auto_deploy_branch}"]
    }
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

  statement {
    actions = ["ecs:UpdateService"]
    resources = [aws_ecs_service.main.arn]
  }
}

resource "aws_iam_role" "deploy" {
  name = "${var.name}-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
  
  inline_policy {
    name = "deploy"
    policy = data.aws_iam_policy_document.ecs_deploy.json
  }
}