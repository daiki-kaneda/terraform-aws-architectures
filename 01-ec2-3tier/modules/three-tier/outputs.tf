output "alb_dns_name" {
  description = "DNS name of the public application load balancer."
  value       = module.alb.dns_name
}

output "rds_endpoint" {
  description = "Connection endpoint for the RDS instance."
  value       = module.db.db_instance_endpoint
}

output "rds_username" {
  description = "Username of RDS instance."
  value = module.db.db_instance_username
}

output "rds_master_user_secret_arn" {
  description = "SecretManager arn of DB Password."
  value = module.db.db_instance_master_user_secret_arn
}
