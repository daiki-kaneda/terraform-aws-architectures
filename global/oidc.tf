locals {
  github_hostname   = "token.actions.githubusercontent.com"
  github_audience   = "sts.amazonaws.com"
  organization_name = "daiki-kaneda"
  repository_names  = ["terraform-aws-architectures"]
}


##################
# IDプロバイダ
##################
data "tls_certificate" "github" {
  url = "https://${local.github_hostname}"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = data.tls_certificate.github.url
  client_id_list  = [local.github_audience]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

##################
# IAMロール
##################
resource "aws_iam_role" "github_admin" {
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume_role.json
  description        = "iam role assumed by Github Actions via OIDC provider"
  name               = "GithubActions-ExcutionRole"
}
data "aws_iam_policy" "admin" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
resource "aws_iam_role_policy_attachment" "github" {
  role       = aws_iam_role.github_admin.name
  policy_arn = data.aws_iam_policy.admin.arn
}

data "aws_iam_policy_document" "github_oidc_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_hostname}:aud"
      values   = [local.github_audience]
    }

    condition {
      test     = "StringLike"
      variable = "${local.github_hostname}:sub"
      values = flatten(
        [
        for repo in local.repository_names :
        [
            "repo:${local.organization_name}/${repo}:ref:refs/heads/main",
            "repo:${local.organization_name}/${repo}:pull_request",
        ]
      ]
      )
    }
  }
}

