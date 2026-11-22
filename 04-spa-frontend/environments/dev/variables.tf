variable "enable_waf" {
  type        = bool
  description = "CloudFront に WAF を付けるかどうか。"
  default     = false

  validation {
    condition     = var.enable_waf == false
    error_message = "開発環境では WAF の料金を避けるため、無効にしてください。"
  }
}

variable "enable_cache" {
  type        = bool
  description = "CloudFront で静的ファイルをキャッシュするかどうか。"
  default     = false

  validation {
    condition     = var.enable_cache == false
    error_message = "開発環境では配信内容をすぐ確認できるよう、キャッシュを使いません。false にしてください。"
  }
}

variable "price_class" {
  type        = string
  description = "CloudFront の料金クラス。日本のエッジを含むのは PriceClass_200 と PriceClass_All です。"
  default     = "PriceClass_200"

  validation {
    condition     = var.price_class == "PriceClass_200"
    error_message = "開発環境では日本を含み、全世界には広げない PriceClass_200 にしてください。"
  }
}

variable "domain_name" {
  type        = string
  description = "独自ドメイン。null のときは CloudFront のデフォルト証明書を使います。"
  default     = null

  validation {
    condition     = var.domain_name == null
    error_message = "開発環境では証明書と DNS の料金を避けるため、独自ドメインは使いません。null のままにしてください。"
  }
}

variable "route53_zone_id" {
  type        = string
  description = "独自ドメインのレコードを作る Route 53 ホストゾーン ID。使わないときは null です。"
  default     = null

  validation {
    condition     = var.route53_zone_id == null
    error_message = "開発環境では Route 53 のレコードを作りません。null のままにしてください。"
  }
}
