module "app_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.project_name}-app"
  description = "Application instances"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
    http = {
      description                  = "HTTP from the load balancer"
      from_port                    = 80
      to_port                      = 80
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.alb.security_group_id
    }
  }

  egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

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
      referenced_security_group_id = module.app_sg.id
    }
  }
}
