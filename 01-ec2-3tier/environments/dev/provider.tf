terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
  backend "s3" {
    bucket       = "terraform-aws-architectures-backend-e69de93d"
    key          = "01-ec2-3tier-dev/state.tfstate"
    use_lockfile = true
    region       = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Project     = "01-ec2-3tier-dev"
      Environment = "Dev"
      ManagedBy   = "Terraform"
    }
  }
}