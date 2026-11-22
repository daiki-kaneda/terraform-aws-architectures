data "aws_route53_zone" "selected" {
  count = local.use_custom_domain ? 1 : 0

  zone_id = var.domain_config.route53_zone_id
}

resource "terraform_data" "domain_belongs_to_zone" {
  count = local.use_custom_domain ? 1 : 0

  lifecycle {
    precondition {
      condition = (
        var.domain_config.domain_name == local.zone_name ||
        endswith(var.domain_config.domain_name, ".${local.zone_name}")
      )
      error_message = "domain_name は、指定した Route 53 ゾーンの名前か、そのサブドメインにしてください。"
    }
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 6.0"
  count   = local.use_custom_domain ? 1 : 0

  providers = {
    aws = aws.us_east_1
  }

  depends_on = [terraform_data.domain_belongs_to_zone]

  domain_name         = var.domain_config.domain_name
  zone_id             = var.domain_config.route53_zone_id
  validation_method   = "DNS"
  wait_for_validation = true
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 5.0"

  create  = local.use_custom_domain
  zone_id = var.domain_config.route53_zone_id

  depends_on = [terraform_data.domain_belongs_to_zone]

  records = local.use_custom_domain ? [
    {
      name = local.record_name
      type = "A"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name = local.record_name
      type = "AAAA"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      }
    },
  ] : []
}
