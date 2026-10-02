locals {
  github_hostname   = "token.actions.githubusercontent.com"
  github_audience   = "sts.amazonaws.com"
  organization_name = "daiki-kaneda"
  repository_names  = ["terraform-aws-architectures"]
  owner_id          = "126944403"
  repository_id     = "1400893427"

  role_types = {
    apply = {
      name        = "GithubActions-ExcutionRole"
      description = "iam role assumed by Github Actions via OIDC provider for apply"
      policy_arns = [data.aws_iam_policy.admin.arn]
    }
    plan = {
      name        = "GithubActions-ExcutionRole-Plan"
      description = "iam role assumed by Github Actions via OIDC provider for plan"
      policy_arns = [data.aws_iam_policy.readonly.arn, resource.aws_iam_policy.s3_plan_policy.arn]
    }
  }

  role_policy_attachments = flatten([for key, value in local.role_types : [
    for policy_arn in value.policy_arns :
    {
      key        = key
      policy_arn = policy_arn
    }
    ]
  ])
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

resource "aws_iam_role" "github" {
  for_each           = toset(keys(local.role_types))
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume_role[each.key].json
  description        = local.role_types[each.key].description
  name               = local.role_types[each.key].name
}


resource "aws_iam_role_policy_attachment" "github" {
  count = length(local.role_policy_attachments)
  role = aws_iam_role.github[
    local.role_policy_attachments[count.index].key
  ].name
  policy_arn = local.role_policy_attachments[count.index].policy_arn
}

##################
# トラストポリシー
##################
data "aws_iam_policy_document" "github_oidc_assume_role" {
  for_each = {
    plan  = "pull_request"
    apply = "ref:refs/heads/main"
  }
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
      test     = "StringEquals"
      variable = "${local.github_hostname}:sub"
      values = flatten(
        [
          for repo in local.repository_names :
          [
            "repo:${local.organization_name}@${local.owner_id}/${repo}@${local.repository_id}:${each.value}",
          ]
        ]
      )
    }
  }
}

resource "aws_iam_policy" "s3_plan_policy" {
  name        = "S3PlanPolicy"
  description = "iam policy for handling tflock file in S3"
  policy      = data.aws_iam_policy_document.s3_plan_policy.json
}
