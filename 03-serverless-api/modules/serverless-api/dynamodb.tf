locals {
  global_secondary_indexes = [
    for index in [
      { name = "GSI1", hash_key = "gsi1pk", range_key = "gsi1sk" },
      { name = "GSI2", hash_key = "gsi2pk", range_key = "gsi2sk" },
      ] : merge(
      {
        name            = index.name
        hash_key        = index.hash_key
        range_key       = index.range_key
        projection_type = "ALL"
      },
      var.dynamodb_config.billing_mode == "PROVISIONED" ? {
        read_capacity  = var.dynamodb_config.read_capacity
        write_capacity = var.dynamodb_config.write_capacity
      } : {}
    )
  ]
}

module "dynamodb" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 5.0"

  name      = var.project_name
  hash_key  = "pk"
  range_key = "sk"

  attributes = [
    { name = "pk", type = "S" },
    { name = "sk", type = "S" },
    { name = "gsi1pk", type = "S" },
    { name = "gsi1sk", type = "S" },
    { name = "gsi2pk", type = "S" },
    { name = "gsi2sk", type = "S" },
  ]

  global_secondary_indexes = local.global_secondary_indexes

  billing_mode                   = var.dynamodb_config.billing_mode
  read_capacity                  = var.dynamodb_config.read_capacity
  write_capacity                 = var.dynamodb_config.write_capacity
  point_in_time_recovery_enabled = var.dynamodb_config.point_in_time_recovery
  deletion_protection_enabled    = var.dynamodb_config.deletion_protection
}
