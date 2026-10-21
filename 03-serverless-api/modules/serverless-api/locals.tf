locals {
  handler_module = replace(trimsuffix(var.handler_file, ".py"), "/", ".")
  lambda_handler = "${local.handler_module}.lambda_handler"

  # templatestring は使わない。仕様書内の $context を Terraform が展開しないようにする。
  openapi_body = replace(var.openapi_spec, "__LAMBDA_ARN__", module.lambda.lambda_function_arn)
}
