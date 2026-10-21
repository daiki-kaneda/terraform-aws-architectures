terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.44"
    }
  }
  backend "s3" {
    bucket       = "terraform-aws-architectures-backend-e69de93d"
    key          = "03-serverless-api-dev/state.tfstate"
    use_lockfile = true
    region       = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Project     = "03-serverless-api-dev"
      Environment = "Dev"
      ManagedBy   = "Terraform"
    }
  }
}