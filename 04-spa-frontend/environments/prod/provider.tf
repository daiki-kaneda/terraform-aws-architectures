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
    key          = "04-spa-frontend-prod/state.tfstate"
    use_lockfile = true
    region       = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Project     = "04-spa-frontend-prod"
      Environment = "Prod"
      ManagedBy   = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = {
      Project     = "04-spa-frontend-prod"
      Environment = "Prod"
      ManagedBy   = "Terraform"
    }
  }
}
