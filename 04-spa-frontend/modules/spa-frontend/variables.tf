variable "project_name" {
  type        = string
  description = "リソース名の接頭語として使われるプロジェクト名"

  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]{0,38}[a-z0-9])?$", var.project_name))
    error_message = "プロジェクト名は小文字、数字、ハイフンだけで、40文字以内にしてください。先頭と末尾はハイフンにできません。"
  }
}

variable "cloudfront_config" {
  type = object({
    enable_waf   = bool
    enable_cache = bool
    price_class  = string
  })
  description = <<-EOT
  CloudFrontのWAF、キャッシュ、料金クラス。
  WAFを有効にすると、us-east-1 に CLOUDFRONT スコープの Web ACL を作り、ディストリビューションへ付けます。
  キャッシュを切ると CachingDisabled、入れると静的配信用の CachingOptimized を使います。
  EOT

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.cloudfront_config.price_class)
    error_message = "price_class は PriceClass_100、PriceClass_200、PriceClass_All のいずれかにしてください。日本のエッジを含むのは PriceClass_200 と PriceClass_All です。"
  }
}

variable "domain_config" {
  type = object({
    domain_name     = optional(string)
    route53_zone_id = optional(string)
  })
  description = <<-EOT
  独自ドメイン。両方を書くと、us-east-1 の ACM 証明書、CloudFront の別名、Route 53 の A と AAAA を作ります。
  両方を書かないときは、CloudFront のデフォルト証明書のままです。
  EOT

  validation {
    condition = (
      var.domain_config.domain_name == null && var.domain_config.route53_zone_id == null
      ) || (
      var.domain_config.domain_name != null && var.domain_config.route53_zone_id != null
    )
    error_message = "独自ドメインを使うときは domain_name と route53_zone_id の両方が必要です。使わないときは両方を書かないでください。"
  }

  validation {
    condition = (
      var.domain_config.domain_name == null ||
      can(regex("^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]{2,}$", var.domain_config.domain_name))
    )
    error_message = "domain_name は app.example.com のような小文字のドメイン名にしてください。"
  }

  validation {
    condition = (
      var.domain_config.route53_zone_id == null ||
      can(regex("^Z[A-Z0-9]+$", var.domain_config.route53_zone_id))
    )
    error_message = "route53_zone_id は Z で始まる Route 53 のホストゾーン ID にしてください。"
  }
}
