output "cloudfront_domain_name" {
  description = "エントリポイントになるCloudFrontのドメイン名。"
  value       = module.serverless_api.cloudfront_domain_name
}

output "api_endpoint" {
  description = "API Gatewayのexecute-api URL。CloudFrontを経由しない呼び出し先です。"
  value       = module.serverless_api.api_endpoint
}

output "lambda_function_name" {
  description = "CDがコードを差し替えるLambda関数名。"
  value       = module.serverless_api.lambda_function_name
}

output "artifacts_bucket_name" {
  description = "CDがzipを置くS3バケット名。"
  value       = module.serverless_api.artifacts_bucket_name
}

output "dynamodb_table_name" {
  description = "アプリケーションが使うDynamoDBテーブル名。"
  value       = module.serverless_api.dynamodb_table_name
}
