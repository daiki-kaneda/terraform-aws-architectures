module "artifacts" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.0"

  bucket_prefix = "${var.project_name}-lambda-"
  # CDが置いたzipが残っていても、環境を消せるようにする。
  force_destroy = true

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      id      = "expire-noncurrent-artifacts"
      enabled = true
      noncurrent_version_expiration = {
        days = var.artifact_noncurrent_expiration_days
      }
    }
  ]
}
