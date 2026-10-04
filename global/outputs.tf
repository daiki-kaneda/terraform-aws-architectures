output "backend_bucket_name" {
  value = aws_s3_bucket.this.id
}

output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "github_oidc_provider_url" {
  value = aws_iam_openid_connect_provider.github.url
}

output "region" {
  value = data.aws_region.this.region
}

output "iam_role_arns" {
  value = {
    apply = aws_iam_role.github["apply"].arn
    plan  = aws_iam_role.github["plan"].arn
  }
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
output "ecr_repository_arn" {
  value = module.ecr.repository_arn
}
output "ecr_repository_name" {
  value = module.ecr.repository_name
}