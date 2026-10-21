variable "handler_file" {
  type        = string
  description = "Lambdaが呼び出すPythonファイル。zipの中のパスです。"
  default     = "app/handler.py"

  validation {
    condition     = var.handler_file == "app/handler.py"
    error_message = "開発環境のハンドラは app/handler.py に固定しています。そのパスにしてください。"
  }
}

variable "lambda_memory_size" {
  type        = number
  description = "Lambdaのメモリ割当(MB)。"
  default     = 128

  validation {
    condition     = contains([128, 256], var.lambda_memory_size)
    error_message = "開発環境では料金を抑えるため、メモリは 128 または 256 MB にしてください。"
  }
}

variable "lambda_timeout" {
  type        = number
  description = "Lambdaのタイムアウト(秒)。"
  default     = 3

  validation {
    condition     = var.lambda_timeout == 3
    error_message = "開発環境では短い実行に固定しています。タイムアウトは 3 秒にしてください。"
  }
}

variable "log_retention_in_days" {
  type        = number
  description = "LambdaのログをCloudWatch Logsに残す日数。"
  default     = 7

  validation {
    condition     = var.log_retention_in_days == 7
    error_message = "ログの保管料金を抑えるため、保持日数は 7 日にしてください。"
  }
}

variable "tracing_mode" {
  type        = string
  description = "LambdaのX-Ray。Active はトレースを記録し、PassThrough は上流から来たトレースを通すだけです。"
  default     = "PassThrough"

  validation {
    condition     = var.tracing_mode == "PassThrough"
    error_message = "開発環境ではX-Rayの料金を避けるため、PassThrough にしてください。"
  }
}

variable "reserved_concurrent_executions" {
  type        = number
  description = "Lambdaの予約同時実行。null のときは予約しません。"
  default     = null

  validation {
    condition     = var.reserved_concurrent_executions == null
    error_message = "開発環境では同時実行を予約しません。null のままにしてください。"
  }
}

variable "enable_waf" {
  type        = bool
  description = "HTTP APIのステージにWAFを関連付けるかどうか。"
  default     = false

  validation {
    condition     = var.enable_waf == false
    error_message = "開発環境ではWAFの料金を避けるため、無効にしてください。"
  }
}

variable "stage_name" {
  type        = string
  description = "HTTP APIのステージ名。"
  default     = "$default"

  validation {
    condition     = var.stage_name == "$default"
    error_message = "開発環境のURLにステージ名を付けないため、$default にしてください。"
  }
}

variable "throttling_rate_limit" {
  type        = number
  description = "HTTP APIの定常的なリクエストレート(リクエスト/秒)。"
  default     = 10

  validation {
    condition     = var.throttling_rate_limit == 10
    error_message = "開発環境のレート制限は 10 リクエスト/秒に固定しています。"
  }
}

variable "throttling_burst_limit" {
  type        = number
  description = "HTTP APIが短時間に受け付けるリクエスト数。"
  default     = 20

  validation {
    condition     = var.throttling_burst_limit == 20
    error_message = "開発環境のバーストは 20 に固定しています。"
  }
}

variable "detailed_metrics_enabled" {
  type        = bool
  description = "API Gatewayの詳細メトリクスを有効にするかどうか。"
  default     = false

  validation {
    condition     = var.detailed_metrics_enabled == false
    error_message = "開発環境では詳細メトリクスの料金を避けるため、無効にしてください。"
  }
}

variable "access_log_retention_in_days" {
  type        = number
  description = "API Gatewayのアクセスログを残す日数。"
  default     = 7

  validation {
    condition     = var.access_log_retention_in_days == 7
    error_message = "アクセスログの保管料金を抑えるため、保持日数は 7 日にしてください。"
  }
}

variable "cors_allow_origins" {
  type        = list(string)
  description = "CORSで許可するオリジン。null のときはCORSを付けません。"
  default     = null

  validation {
    condition     = var.cors_allow_origins == null
    error_message = "開発環境ではCORSを付けません。null のままにしてください。"
  }
}

variable "enable_cache" {
  type        = bool
  description = "CloudFrontでGETとHEADをキャッシュするかどうか。"
  default     = false

  validation {
    condition     = var.enable_cache == false
    error_message = "開発環境ではCloudFrontのキャッシュを使いません。false にしてください。"
  }
}

variable "cache_ttl" {
  type = object({
    min_ttl     = number
    default_ttl = number
    max_ttl     = number
  })
  description = "CloudFrontのキャッシュTTL(秒)。キャッシュが無効のときは使いません。"
  default = {
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  validation {
    condition = (
      var.cache_ttl.min_ttl == 0 &&
      var.cache_ttl.default_ttl == 0 &&
      var.cache_ttl.max_ttl == 0
    )
    error_message = "開発環境ではキャッシュを使わないため、TTLはすべて 0 にしてください。"
  }
}

variable "billing_mode" {
  type        = string
  description = "DynamoDBの課金モード。"
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = var.billing_mode == "PAY_PER_REQUEST"
    error_message = "開発環境では使った分だけのオンデマンドにします。PAY_PER_REQUEST にしてください。"
  }
}

variable "read_capacity" {
  type        = number
  description = "DynamoDBの読み取りキャパシティ。オンデマンドでは null です。"
  default     = null

  validation {
    condition     = var.read_capacity == null
    error_message = "オンデマンドでは読み取りキャパシティを指定できません。null のままにしてください。"
  }
}

variable "write_capacity" {
  type        = number
  description = "DynamoDBの書き込みキャパシティ。オンデマンドでは null です。"
  default     = null

  validation {
    condition     = var.write_capacity == null
    error_message = "オンデマンドでは書き込みキャパシティを指定できません。null のままにしてください。"
  }
}

variable "point_in_time_recovery" {
  type        = bool
  description = "DynamoDBのポイントインタイムリカバリを有効にするかどうか。"
  default     = false

  validation {
    condition     = var.point_in_time_recovery == false
    error_message = "開発環境ではポイントインタイムリカバリの料金を避けるため、無効にしてください。"
  }
}

variable "deletion_protection" {
  type        = bool
  description = "DynamoDBの削除保護を有効にするかどうか。"
  default     = false

  validation {
    condition     = var.deletion_protection == false
    error_message = "開発環境のテーブルは消せるようにします。削除保護は無効にしてください。"
  }
}

variable "artifact_noncurrent_expiration_days" {
  type        = number
  description = "デプロイ用バケットの現行でないzipを消すまでの日数。"
  default     = 7

  validation {
    condition     = var.artifact_noncurrent_expiration_days == 7
    error_message = "開発環境では古いzipを 7 日で消します。7 に設定してください。"
  }
}
