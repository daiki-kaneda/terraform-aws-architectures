module "three_tier" {
  source = "../modules/three-tier"

  project_name = "ec2-3tier-dev"

  vpc_config = {
    cidr               = "10.0.0.0/16"
    azs                = ["ap-northeast-1a", "ap-northeast-1c"]
    public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
    private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
    database_subnets   = ["10.0.201.0/24", "10.0.202.0/24"]
    enable_nat_gateway = var.enable_nat_gateway
  }

  asg_config = {
    instance_type     = var.instance_type
    min_size          = var.min_size
    max_size          = var.max_size
    desired_capacity  = var.desired_capacity
    use_public_subnet = var.use_public_subnet
    single_az         = var.single_az
  }

  rds_config = {
    instance_class    = var.instance_class
    allocated_storage = var.allocated_storage
    multi_az          = var.multi_az
  }

  alb_config = {
    enable_waf   = var.enable_waf
    enable_https = var.enable_https
  }
}
