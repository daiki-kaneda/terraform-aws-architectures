locals {
  use_custom_domain = var.domain_config.domain_name != null
  zone_name         = local.use_custom_domain ? trimsuffix(data.aws_route53_zone.selected[0].name, ".") : null
  # ゾーンの頂点は空文字。サブドメインはゾーン名を除いた相対名にする。
  record_name = local.use_custom_domain ? (
    var.domain_config.domain_name == local.zone_name ? "" : trimsuffix(var.domain_config.domain_name, ".${local.zone_name}")
  ) : ""

  cache_policy_name = var.cloudfront_config.enable_cache ? "Managed-CachingOptimized" : "Managed-CachingDisabled"
}
