module "db_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.project_name}-db"
  description = "RDS MySQL"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
    mysql = {
      description                  = "MySQL from application instances"
      from_port                    = 3306
      to_port                      = 3306
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.ecs_service.security_group_id
    }
  }
}
