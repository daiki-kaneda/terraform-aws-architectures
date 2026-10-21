output "cloudfront_domain_name" {
  description = "公開入口になるCloudFrontのドメイン名"
  value       = module.cloudfront.cloudfront_distribution_domain_name
}

output "api_endpoint" {
  description = "API Gatewayのexecute-api URL。CloudFrontを経由しない呼び出し先です。"
  value       = module.api_gateway.stage_invoke_url
}

output "lambda_function_name" {
  description = "CDがコードを差し替えるLambda関数名"
  value       = module.lambda.lambda_function_name
}

output "artifacts_bucket_name" {
  description = "CDがzipを置くS3バケット名"
  value       = module.artifacts.s3_bucket_id
}

output "dynamodb_table_name" {
  description = "アプリケーションが使うDynamoDBテーブル名。LambdaのTABLE_NAMEと同じです。"
  value       = module.dynamodb.dynamodb_table_id
}
