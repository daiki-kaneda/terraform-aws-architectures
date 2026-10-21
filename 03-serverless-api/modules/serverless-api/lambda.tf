resource "archive_file" "placeholder" {
  type        = "zip"
  output_path = "${path.module}/.build/placeholder.zip"

  source {
    content  = <<-PY
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": "{\"message\": \"placeholder\"}",
    }
PY
    filename = var.handler_file
  }
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.0"

  function_name = "${var.project_name}-api"
  handler       = local.lambda_handler
  runtime       = "python3.13"
  architectures = ["arm64"]

  memory_size                       = var.lambda_config.memory_size
  timeout                           = var.lambda_config.timeout
  reserved_concurrent_executions    = coalesce(var.lambda_config.reserved_concurrent_executions, -1)
  tracing_mode                      = var.lambda_config.tracing_mode
  attach_tracing_policy             = var.lambda_config.tracing_mode == "Active"
  cloudwatch_logs_retention_in_days = var.lambda_config.log_retention_in_days

  # 初回だけこのzipを置く。以後のコードはCDが更新し、Terraformはハッシュを見ない。
  create_package          = false
  local_existing_package  = archive_file.placeholder.output_path
  ignore_source_code_hash = true

  environment_variables = {
    TABLE_NAME = module.dynamodb.dynamodb_table_id
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow"
      actions = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
      ]
      resources = [
        module.dynamodb.dynamodb_table_arn,
        "${module.dynamodb.dynamodb_table_arn}/index/*",
      ]
    }
  }
}
