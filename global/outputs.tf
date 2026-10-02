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

output "iam_role_arn" {
  value = aws_iam_role.github_admin.arn
}