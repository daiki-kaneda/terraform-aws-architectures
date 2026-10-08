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

output "app_ami_parameter_name" {
  description = "アプリAMI IDを入れるSSMパラメータ名。"
  value       = aws_ssm_parameter.app_ami.name
}

output "autoscaling_group_name" {
  description = "アプリを載せるAuto Scalingグループ名。"
  value       = module.asg.autoscaling_group_name
}
