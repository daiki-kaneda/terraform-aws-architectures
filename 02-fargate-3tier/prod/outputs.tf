output "alb_dns_name" {
  description = "パブリックALBのDNS名。"
  value       = module.three_tier.alb_dns_name
}

output "rds_endpoint" {
  description = "RDSインスタンスのエンドポイント。"
  value       = module.three_tier.rds_endpoint
}

output "rds_username" {
  description = "RDSインスタンスのユーザーネーム。"
  sensitive   = true
  value       = module.three_tier.rds_username
}

output "rds_master_user_secret_arn" {
  description = "RDSのパスワードが保存されているSecretManagerのArn。"
  value       = module.three_tier.rds_master_user_secret_arn
}
