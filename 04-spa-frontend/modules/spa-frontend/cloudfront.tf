module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 6.6"

  comment         = var.project_name
  enabled         = true
  is_ipv6_enabled = true
  price_class     = var.cloudfront_config.price_class
  aliases         = local.use_custom_domain ? [var.domain_config.domain_name] : null
  web_acl_id      = var.cloudfront_config.enable_waf ? module.waf.web_acl_arn : null

  # 名前を環境ごとに分ける。既定の "s3" のままだと、dev と prod で OAC が衝突する。
  origin_access_control = {
    s3 = {
      name             = "${var.project_name}-s3"
      description      = "${var.project_name} の S3 を CloudFront だけが読む"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    s3 = {
      domain_name               = module.website.s3_bucket_bucket_regional_domain_name
      origin_access_control_key = "s3"
    }
  }

  default_root_object = "index.html"

  default_cache_behavior = {
    target_origin_id       = "s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_name      = local.cache_policy_name
  }

  # OAC 経由の S3 は、存在しないキーに 403 を返す。画面のパスは index.html に戻す。
  custom_error_response = [
    {
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 0
    },
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 0
    },
  ]

  viewer_certificate = {
    acm_certificate_arn            = local.use_custom_domain ? module.acm[0].acm_certificate_arn : null
    cloudfront_default_certificate = local.use_custom_domain ? null : true
    ssl_support_method             = local.use_custom_domain ? "sni-only" : null
    # デフォルト証明書では TLSv1 だけ指定できる。
    minimum_protocol_version = local.use_custom_domain ? "TLSv1.2_2021" : "TLSv1"
  }
}
