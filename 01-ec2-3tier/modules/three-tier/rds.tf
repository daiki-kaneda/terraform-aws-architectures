module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.project_name}-mysql"

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.rds_config.instance_class
  allocated_storage = var.rds_config.allocated_storage
  multi_az          = var.rds_config.multi_az

  db_name  = "app"
  username = "app"
  port     = 3306

  vpc_security_group_ids = [module.db_sg.id]

  create_db_subnet_group = true
  subnet_ids             = module.vpc.database_subnets

  family               = "mysql8.0"
  major_engine_version = "8.0"

  manage_master_user_password = true
  deletion_protection         = false
  skip_final_snapshot         = true
}
