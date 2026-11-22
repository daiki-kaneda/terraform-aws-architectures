output "website_url" {
  description = "公開URL。独自ドメインがあるときはそのURL、ないときは CloudFront のドメインです。"
  value       = local.use_custom_domain ? "https://${var.domain_config.domain_name}" : "https://${module.cloudfront.cloudfront_distribution_domain_name}"
}

output "cloudfront_domain_name" {
  description = "CloudFront のドメイン名"
  value       = module.cloudfront.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_id" {
  description = "CD がキャッシュを無効化する CloudFront ディストリビューション ID"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "bucket_name" {
  description = "CD が静的ファイルを置く S3 バケット名"
  value       = module.website.s3_bucket_id
}
