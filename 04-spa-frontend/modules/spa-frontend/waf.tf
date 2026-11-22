# CloudFront に付ける WAF は us-east-1 に作る。関連付けはディストリビューションの web_acl_id で行う。
module "waf" {
  source  = "terraform-aws-modules/wafv2/aws"
  version = "~> 2.0"

  providers = {
    aws = aws.us_east_1
  }

  create         = var.cloudfront_config.enable_waf
  name           = "${var.project_name}-waf"
  scope          = "CLOUDFRONT"
  default_action = "allow"

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
