output "alb_dns_name" {
  description = "パブリックALBのDNS名"
  value       = module.alb.dns_name
}

output "rds_endpoint" {
  description = "RDSインスタンスのエンドポイント"
  value       = module.db.db_instance_endpoint
}

output "rds_username" {
  description = "RDSインスタンスのユーザーネーム"
  value       = module.db.db_instance_username
}

output "rds_master_user_secret_arn" {
  description = "RDSのパスワードが保存されているSecretManagerのArn"
  value       = module.db.db_instance_master_user_secret_arn
}

output "ecs_cluster_name" {
  description = "アプリを載せるECSクラスタ名。"
  value       = "${var.project_name}-cluster"
}

output "ecs_service_name" {
  description = "アプリを載せるECSサービス名。"
  value       = "${var.project_name}-service"
}
