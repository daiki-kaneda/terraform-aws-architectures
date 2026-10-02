module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.project_name
  cidr = var.vpc_config.cidr

  azs              = var.vpc_config.azs
  public_subnets   = var.vpc_config.public_subnets
  private_subnets  = var.vpc_config.private_subnets
  database_subnets = var.vpc_config.database_subnets

  enable_nat_gateway     = var.vpc_config.enable_nat_gateway
  one_nat_gateway_per_az = var.vpc_config.enable_nat_gateway
}
