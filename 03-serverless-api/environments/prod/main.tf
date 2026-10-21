module "serverless_api" {
  source = "../../modules/serverless-api"

  project_name = "serverless-api-prod"
  handler_file = var.handler_file
  openapi_spec = file("${path.module}/../../app/openapi.yaml")

  lambda_config = {
    memory_size                    = var.lambda_memory_size
    timeout                        = var.lambda_timeout
    log_retention_in_days          = var.log_retention_in_days
    tracing_mode                   = var.tracing_mode
    reserved_concurrent_executions = var.reserved_concurrent_executions
  }

  api_config = {
    enable_waf                   = var.enable_waf
    stage_name                   = var.stage_name
    throttling_rate_limit        = var.throttling_rate_limit
    throttling_burst_limit       = var.throttling_burst_limit
    detailed_metrics_enabled     = var.detailed_metrics_enabled
    access_log_retention_in_days = var.access_log_retention_in_days
    cors_allow_origins           = var.cors_allow_origins
  }

  cloudfront_config = {
    enable_cache = var.enable_cache
    min_ttl      = var.cache_ttl.min_ttl
    default_ttl  = var.cache_ttl.default_ttl
    max_ttl      = var.cache_ttl.max_ttl
  }

  dynamodb_config = {
    billing_mode           = var.billing_mode
    read_capacity          = var.read_capacity
    write_capacity         = var.write_capacity
    point_in_time_recovery = var.point_in_time_recovery
    deletion_protection    = var.deletion_protection
  }

  artifact_noncurrent_expiration_days = var.artifact_noncurrent_expiration_days
}
