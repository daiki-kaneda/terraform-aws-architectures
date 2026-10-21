variable "handler_file" {
  type        = string
  description = "Lambdaが呼び出すPythonファイル。zipの中のパスです。"
  default     = "app/handler.py"

  validation {
    condition     = var.handler_file == "app/handler.py"
    error_message = "本番環境のハンドラは app/handler.py に固定しています。そのパスにしてください。"
  }
}

variable "lambda_memory_size" {
  type        = number
  description = "Lambdaのメモリ割当(MB)。"
  default     = 512

  validation {
    condition     = contains([512, 1024], var.lambda_memory_size)
    error_message = "本番環境ではLambdaのメモリは 512 または 1024 MB にしてください。"
  }
}

variable "lambda_timeout" {
  type        = number
  description = "Lambdaのタイムアウト(秒)。"
  default     = 5

  validation {
    condition = var.lambda_timeout >= 5 && var.lambda_timeout <= 30
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-quotas.html
    error_message = "本番のタイムアウトは 5 から 30 秒です。HTTP APIの統合は 30 秒で切れます。"
  }
}

variable "log_retention_in_days" {
  type        = number
  description = "LambdaのログをCloudWatch Logsに残す日数。"
  default     = 30

  validation {
    condition     = contains([30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_in_days)
    error_message = "障害調査のため、ログは30日以上残してください。30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 のいずれかにしてください。"
  }
}

variable "tracing_mode" {
  type        = string
  description = "LambdaのX-Ray。Active はトレースを記録し、PassThrough は上流から来たトレースを通すだけです。"
  default     = "Active"

  validation {
    condition     = var.tracing_mode == "Active"
    error_message = "本番では障害調査のため、X-Rayを Active にしてください。"
  }
}

variable "reserved_concurrent_executions" {
  type        = number
  description = "Lambdaの予約同時実行。null のときは予約しません。"
  default     = 20

  validation {
    condition = (
      var.reserved_concurrent_executions != null &&
      var.reserved_concurrent_executions >= 10 &&
      var.reserved_concurrent_executions <= 100
    )
    error_message = "本番では同時実行を予約し、アカウント全体の枯渇を防ぎます。10 から 100 にしてください。"
  }
}

variable "enable_waf" {
  type        = bool
  description = "HTTP APIのステージにWAFを関連付けるかどうか。"
  default     = true

  validation {
    condition     = var.enable_waf == true
    error_message = "本番環境ではインターネットからの不正なリクエストをWAFで止めます。true にしてください。"
  }
}

variable "stage_name" {
  type        = string
  description = "HTTP APIのステージ名。"
  default     = "$default"

  validation {
    condition     = var.stage_name == "$default"
    error_message = "本番のURLにステージ名を付けないため、$default にしてください。"
  }
}

variable "throttling_rate_limit" {
  type        = number
  description = "HTTP APIの定常的なリクエストレート(リクエスト/秒)。"
  default     = 100

  validation {
    condition     = var.throttling_rate_limit == 100
    error_message = "本番環境のレート制限は 100 リクエスト/秒に固定しています。"
  }
}

variable "throttling_burst_limit" {
  type        = number
  description = "HTTP APIが短時間に受け付けるリクエスト数。"
  default     = 200

  validation {
    condition     = var.throttling_burst_limit == 200
    error_message = "本番環境のバーストは 200 に固定しています。"
  }
}

variable "detailed_metrics_enabled" {
  type        = bool
  description = "API Gatewayの詳細メトリクスを有効にするかどうか。"
  default     = true

  validation {
    condition     = var.detailed_metrics_enabled == true
    error_message = "本番ではルートごとのメトリクスを残します。true にしてください。"
  }
}

variable "access_log_retention_in_days" {
  type        = number
  description = "API Gatewayのアクセスログを残す日数。"
  default     = 30

  validation {
    condition     = contains([30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.access_log_retention_in_days)
    error_message = "障害調査のため、アクセスログは30日以上残してください。30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 のいずれかにしてください。"
  }
}

variable "cors_allow_origins" {
  type        = list(string)
  description = "CORSで許可するオリジン。null のときはCORSを付けません。"
  default     = null

  validation {
    condition     = var.cors_allow_origins == null
    error_message = "本番の画面オリジンはまだないため、CORSは付けません。null のままにしてください。"
  }
}

variable "enable_cache" {
  type        = bool
  description = "CloudFrontでGETとHEADをキャッシュするかどうか。"
  default     = true

  validation {
    condition     = var.enable_cache == true
    error_message = "本番ではCloudFrontでGETとHEADをキャッシュします。true にしてください。"
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
    default_ttl = 60
    max_ttl     = 300
  }

  validation {
    condition = (
      var.cache_ttl.min_ttl == 0 &&
      var.cache_ttl.default_ttl == 60 &&
      var.cache_ttl.max_ttl == 300
    )
    error_message = "本番のキャッシュTTLは min 0 秒、default 60 秒、max 300 秒にしてください。"
  }
}

variable "billing_mode" {
  type        = string
  description = "DynamoDBの課金モード。"
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = var.billing_mode == "PAY_PER_REQUEST"
    error_message = "本番も使った分だけのオンデマンドにします。PAY_PER_REQUEST にしてください。"
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
  default     = true

  validation {
    condition     = var.point_in_time_recovery == true
    error_message = "本番のデータ復旧のため、ポイントインタイムリカバリを有効にしてください。"
  }
}

variable "deletion_protection" {
  type        = bool
  description = "DynamoDBの削除保護を有効にするかどうか。"
  default     = true

  validation {
    condition     = var.deletion_protection == true
    error_message = "本番のテーブルを誤って消さないため、削除保護を有効にしてください。"
  }
}

variable "artifact_noncurrent_expiration_days" {
  type        = number
  description = "デプロイ用バケットの現行でないzipを消すまでの日数。"
  default     = 30

  validation {
    condition     = var.artifact_noncurrent_expiration_days == 30
    error_message = "切り戻しのため、古いzipは 30 日残します。30 に設定してください。"
  }
}
