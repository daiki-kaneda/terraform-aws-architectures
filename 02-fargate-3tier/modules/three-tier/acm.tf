module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 6.0"

  create_certificate = var.alb_config.enable_https

  domain_name = coalesce(var.alb_config.domain_name, "disabled.invalid")
  zone_id     = coalesce(var.alb_config.route53_zone_id, "Z00000000000000000000")

  validation_method   = "DNS"
  wait_for_validation = var.alb_config.enable_https
}
