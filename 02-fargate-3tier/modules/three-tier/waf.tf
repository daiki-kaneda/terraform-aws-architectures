module "waf" {
  source  = "terraform-aws-modules/wafv2/aws"
  version = "~> 2.0"

  create         = var.alb_config.enable_waf
  name           = "${var.project_name}-waf"
  scope          = "REGIONAL"
  default_action = "allow"

  association_resource_arns = var.alb_config.enable_waf ? {
    alb = module.alb.arn
  } : {}

  rules = {
    aws-common = {
      priority        = 1
      override_action = "none"
      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }
    }
    known-bad-inputs = {
      priority        = 2
      override_action = "none"
      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor_name = "AWS"
        }
      }
    }
    ip-reputation = {
      priority        = 3
      override_action = "none"
      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesAmazonIpReputationList"
          vendor_name = "AWS"
        }
      }
    }
  }
}
