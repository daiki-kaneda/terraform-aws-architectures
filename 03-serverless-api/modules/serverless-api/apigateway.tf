module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 6.1"

  name          = "${var.project_name}-http"
  protocol_type = "HTTP"
  body          = local.openapi_body

  # ルートはOpenAPIのbodyだけが持つ。Terraform側では作らない。
  create_routes_and_integrations = false

  # カスタムドメインは使わない。execute-apiのURLを残す。
  create_domain_name    = false
  create_domain_records = false
  create_certificate    = false

  cors_configuration = var.api_config.cors_allow_origins == null ? null : {
    allow_headers = ["authorization", "content-type"]
    allow_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    allow_origins = var.api_config.cors_allow_origins
    max_age       = 300
  }

  stage_name = var.api_config.stage_name

  stage_access_log_settings = {
    create_log_group            = true
    log_group_retention_in_days = var.api_config.access_log_retention_in_days
  }

  stage_default_route_settings = {
    detailed_metrics_enabled = var.api_config.detailed_metrics_enabled
    throttling_burst_limit   = var.api_config.throttling_burst_limit
    throttling_rate_limit    = var.api_config.throttling_rate_limit
  }
}

# OpenAPIのbodyからは呼び出し権限が作られない。
resource "aws_lambda_permission" "api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*/*"
}
