variable "enable_waf" {
  type        = bool
  description = "CloudFront に WAF を付けるかどうか。"
  default     = true

  validation {
    condition     = var.enable_waf == true
    error_message = "本番環境ではインターネットからの不正なリクエストを WAF で止めます。true にしてください。"
  }
}

variable "enable_cache" {
  type        = bool
  description = "CloudFront で静的ファイルをキャッシュするかどうか。"
  default     = true

  validation {
    condition     = var.enable_cache == true
    error_message = "本番では CloudFront で静的ファイルをキャッシュします。true にしてください。"
  }
}

variable "price_class" {
  type        = string
  description = "CloudFront の料金クラス。日本のエッジを含むのは PriceClass_200 と PriceClass_All です。"
  default     = "PriceClass_200"

  validation {
    condition     = var.price_class == "PriceClass_200"
    error_message = "本番では日本を含み、全世界には広げない PriceClass_200 にしてください。"
  }
}

variable "domain_name" {
  type        = string
  description = "独自ドメイン。null のときは CloudFront のデフォルト証明書を使います。"
  default     = null

  validation {
    condition = (
      var.domain_name == null && var.route53_zone_id == null
      ) || (
      var.domain_name != null && var.route53_zone_id != null
    )
    error_message = "独自ドメインを使うときは、ドメイン名と Route 53 のゾーン ID を両方指定してください。使わないときは両方とも null です。"
  }
}

variable "route53_zone_id" {
  type        = string
  description = "独自ドメインのレコードを作る Route 53 ホストゾーン ID。使わないときは null です。"
  default     = null
}
