locals {
  http_listener = {
    http = {
      port     = 80
      protocol = "HTTP"

      redirect = var.alb_config.enable_https ? {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      } : null

      forward = var.alb_config.enable_https ? null : {
        target_group_key = "app"
      }
    }
  }

  https_listener = var.alb_config.enable_https ? {
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      forward = {
        target_group_key = "app"
      }
    }
  } : {}
}


module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = var.project_name
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_group_ingress_rules = merge({
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    } },
    var.alb_config.enable_https ? {
      all_https = {
        from_port   = 443
        to_port     = 443
        ip_protocol = "tcp"
        description = "HTTPS web traffic"
        cidr_ipv4   = "0.0.0.0/0"
      }
    } : {}
  )

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = merge(local.http_listener, local.https_listener)

  target_groups = {
    app = {
      protocol          = "HTTP"
      port              = 80
      target_type       = "ip"
      create_attachment = false
    }
  }
}
