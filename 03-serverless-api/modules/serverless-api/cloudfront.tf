module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 6.6"

  comment         = var.project_name
  enabled         = true
  is_ipv6_enabled = true

  # このモジュールの既定はS3用のオリジンアクセスコントロールを作る。APIオリジンでは使わない。
  origin_access_control = {}

  origin = {
    api = {
      domain_name = module.api_gateway.stage_domain_name
      origin_path = var.api_config.stage_name == "$default" ? null : "/${var.api_config.stage_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
        origin_read_timeout    = 60
      }
    }
  }

  default_cache_behavior = {
    target_origin_id         = "api"
    viewer_protocol_policy   = "https-only"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    cache_policy_id          = var.cloudfront_config.enable_cache ? null : data.aws_cloudfront_cache_policy.caching_disabled.id
    cache_policy_key         = var.cloudfront_config.enable_cache ? "api" : null
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id
  }

  cache_policies = var.cloudfront_config.enable_cache ? {
    api = {
      name        = "${var.project_name}-api"
      comment     = "${var.project_name} のクエリ文字列キャッシュ"
      min_ttl     = var.cloudfront_config.min_ttl
      default_ttl = var.cloudfront_config.default_ttl
      max_ttl     = var.cloudfront_config.max_ttl
      parameters_in_cache_key_and_forwarded_to_origin = {
        cookies_config = {
          cookie_behavior = "none"
        }
        headers_config = {
          header_behavior = "none"
        }
        query_strings_config = {
          query_string_behavior = "all"
        }
      }
    }
  } : null

  viewer_certificate = {
    cloudfront_default_certificate = true
    # デフォルト証明書では TLSv1 だけ指定できる。
    minimum_protocol_version = "TLSv1"
  }
}
