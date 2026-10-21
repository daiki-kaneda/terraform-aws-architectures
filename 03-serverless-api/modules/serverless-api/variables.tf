variable "project_name" {
  type        = string
  description = "リソース名の接頭語として使われるプロジェクト名"

  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]{0,38}[a-z0-9])?$", var.project_name))
    error_message = "プロジェクト名は小文字、数字、ハイフンだけで、40文字以内にしてください。先頭と末尾はハイフンにできません。"
  }
}

variable "handler_file" {
  type        = string
  description = "Lambdaが呼び出すPythonファイル。app/handler.py のように指定します。関数名は lambda_handler です。"

  validation {
    condition     = can(regex("^[A-Za-z_][A-Za-z0-9_]*(/[A-Za-z_][A-Za-z0-9_]*)*\\.py$", var.handler_file))
    error_message = "handler_file は app/handler.py のように、Pythonの識別子をスラッシュでつないだ .py ファイルにしてください。"
  }
}

variable "openapi_spec" {
  type        = string
  description = <<-EOT
  HTTP APIのOpenAPI 3.0仕様書。パスとLambda統合をここに書きます。
  統合URIの関数ARNの位置は __LAMBDA_ARN__ にしてください。モジュールが関数のARNに置き換えます。
  EOT

  validation {
    condition     = strcontains(var.openapi_spec, "__LAMBDA_ARN__")
    error_message = "OpenAPI仕様書には、Lambda関数ARNのプレースホルダ __LAMBDA_ARN__ を含めてください。"
  }
}

variable "lambda_config" {
  type = object({
    memory_size                    = number
    timeout                        = number
    log_retention_in_days          = number
    tracing_mode                   = string
    reserved_concurrent_executions = optional(number)
  })
  description = <<-EOT
  Lambdaのメモリ、タイムアウト、ログ保持、X-Ray、予約同時実行。
  timeoutはHTTP APIの統合タイムアウト上限に合わせ、30秒までです。
  reserved_concurrent_executionsを書かないときは、同時実行の予約を付けません。
  EOT

  validation {
    condition     = var.lambda_config.memory_size >= 128 && var.lambda_config.memory_size <= 10240
    error_message = "Lambdaのメモリは 128 から 10240 MB までです。"
  }

  validation {
    condition     = var.lambda_config.timeout >= 1 && var.lambda_config.timeout <= 30
    error_message = "Lambdaのタイムアウトは 1 から 30 秒までです。HTTP APIの統合は30秒で切れます。"
  }

  validation {
    condition = contains(
      [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653],
      var.lambda_config.log_retention_in_days
    )
    error_message = "ログの保持日数は CloudWatch Logs が受け付ける次の日数にしてください: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653。"
  }

  validation {
    condition     = contains(["Active", "PassThrough"], var.lambda_config.tracing_mode)
    error_message = "tracing_mode は Active または PassThrough にしてください。"
  }

  validation {
    condition = (
      var.lambda_config.reserved_concurrent_executions == null ||
      var.lambda_config.reserved_concurrent_executions >= 0
    )
    error_message = "予約同時実行を書くときは 0 以上にしてください。書かないときは上限を付けません。"
  }
}

variable "api_config" {
  type = object({
    enable_waf                   = bool
    stage_name                   = string
    throttling_rate_limit        = number
    throttling_burst_limit       = number
    detailed_metrics_enabled     = bool
    access_log_retention_in_days = number
    cors_allow_origins           = optional(list(string))
  })
  description = <<-EOT
  HTTP APIのステージ、スロットリング、アクセスログ、WAF、CORS。
  cors_allow_originsを書かないときはCORSを付けません。許可オリジンは仕様書ではなくここで環境差にします。
  EOT

  validation {
    condition = (
      var.api_config.stage_name == "$default" ||
      can(regex("^[A-Za-z0-9_-]{1,128}$", var.api_config.stage_name))
    )
    error_message = "ステージ名は $default か、英数字、ハイフン、アンダースコアで128文字以内にしてください。"
  }

  validation {
    condition     = var.api_config.throttling_rate_limit > 0 && var.api_config.throttling_burst_limit > 0
    error_message = "スロットリングのレートとバーストは、どちらも 0 より大きくしてください。"
  }

  validation {
    condition = contains(
      [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653],
      var.api_config.access_log_retention_in_days
    )
    error_message = "アクセスログの保持日数は CloudWatch Logs が受け付ける次の日数にしてください: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653。"
  }

  validation {
    condition = (
      var.api_config.cors_allow_origins == null ||
      length(var.api_config.cors_allow_origins) > 0
    )
    error_message = "CORSを有効にするときは、許可するオリジンを1つ以上書いてください。無効にするときは cors_allow_origins を書かないでください。"
  }
}

variable "cloudfront_config" {
  type = object({
    enable_cache = bool
    min_ttl      = number
    default_ttl  = number
    max_ttl      = number
  })
  description = <<-EOT
  CloudFrontのキャッシュ。無効のときは CachingDisabled を使い、TTLは使いません。
  有効なときはクエリ文字列をキャッシュキーにしたポリシーを使い、TTLはこの値です。
  EOT

  validation {
    condition = !var.cloudfront_config.enable_cache || (
      var.cloudfront_config.min_ttl >= 0 &&
      var.cloudfront_config.min_ttl <= var.cloudfront_config.default_ttl &&
      var.cloudfront_config.default_ttl <= var.cloudfront_config.max_ttl &&
      var.cloudfront_config.max_ttl <= 31536000
    )
    error_message = "キャッシュを有効にするときは、0 <= min_ttl <= default_ttl <= max_ttl <= 31536000 にしてください。単位は秒です。"
  }
}

variable "dynamodb_config" {
  type = object({
    billing_mode           = string
    read_capacity          = optional(number)
    write_capacity         = optional(number)
    point_in_time_recovery = bool
    deletion_protection    = bool
  })
  description = <<-EOT
  DynamoDBの課金、ポイントインタイムリカバリ、削除保護。
  オンデマンドのときはキャパシティを書かないでください。プロビジョンドのときは読み書きのキャパシティが必要です。
  EOT

  validation {
    condition = (
      var.dynamodb_config.billing_mode == "PAY_PER_REQUEST" &&
      var.dynamodb_config.read_capacity == null &&
      var.dynamodb_config.write_capacity == null
      ) || (
      var.dynamodb_config.billing_mode == "PROVISIONED" &&
      try(var.dynamodb_config.read_capacity, 0) >= 1 &&
      try(var.dynamodb_config.write_capacity, 0) >= 1
    )
    error_message = "billing_mode は PAY_PER_REQUEST または PROVISIONED です。オンデマンドではキャパシティを書かず、プロビジョンドでは読み書きを 1 以上にしてください。"
  }
}

variable "artifact_noncurrent_expiration_days" {
  type        = number
  description = "デプロイ用バケットに残った、現行でないzipを消すまでの日数。"

  validation {
    condition     = var.artifact_noncurrent_expiration_days >= 1
    error_message = "古いzipを消すまでの日数は 1 以上にしてください。"
  }
}
