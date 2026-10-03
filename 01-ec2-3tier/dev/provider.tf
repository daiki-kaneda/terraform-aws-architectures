terraform {
  required_version = "> 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Project     = "01-ec2-3tier"
      Environment = "Dev"
      ManagedBy   = "Terraform"
    }
  }
}