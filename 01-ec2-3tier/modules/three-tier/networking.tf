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

resource "terraform_data" "nat_config" {
  lifecycle {
    precondition {
      condition     = var.vpc_config.enable_nat_gateway || var.asg_config.use_public_subnet
      error_message = "NAT Gatewayが無効なのに、インスタンスがプライベートサブネットにあります。このままだとインスタンスからインターネットへ出られません。NAT Gatewayを有効にするか、パブリックサブネットを使ってください。"
    }

    precondition {
      condition     = !(var.vpc_config.enable_nat_gateway && var.asg_config.use_public_subnet)
      error_message = "パブリックサブネットを使っているのにNAT Gatewayが有効です。外への出口が二重になり、NATの料金だけ増えます。NAT Gatewayを無効にするか、プライベートサブネットを使ってください。"
    }
  }
}