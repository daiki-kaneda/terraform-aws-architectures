module "spa_frontend" {
  source = "../../modules/spa-frontend"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  project_name = "spa-frontend-prod"

  cloudfront_config = {
    enable_waf   = var.enable_waf
    enable_cache = var.enable_cache
    price_class  = var.price_class
  }

  domain_config = {
    domain_name     = var.domain_name
    route53_zone_id = var.route53_zone_id
  }
}
