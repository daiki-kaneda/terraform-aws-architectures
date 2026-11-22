output "website_url" {
  description = "公開URL。"
  value       = module.spa_frontend.website_url
}

output "cloudfront_domain_name" {
  description = "CloudFront のドメイン名。"
  value       = module.spa_frontend.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "CD がキャッシュを無効化する CloudFront ディストリビューション ID。"
  value       = module.spa_frontend.cloudfront_distribution_id
}

output "bucket_name" {
  description = "CD が静的ファイルを置く S3 バケット名。"
  value       = module.spa_frontend.bucket_name
}
