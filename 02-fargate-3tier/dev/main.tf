module "three_tier" {
  source = "../modules/three-tier"

  project_name = "fargate-3tier-dev"

  vpc_config = {
    cidr               = "10.0.0.0/16"
    azs                = ["ap-northeast-1a", "ap-northeast-1c"]
    public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
    private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
    database_subnets   = ["10.0.201.0/24", "10.0.202.0/24"]
    enable_nat_gateway = var.enable_nat_gateway
  }

  fargate_config = {
    cpu               = var.task_size.cpu
    memory            = var.task_size.memory
    assign_public_ip  = var.assign_public_ip
    use_public_subnet = var.use_public_subnet
    single_az         = var.single_az
    min_capacity      = var.min_capacity
    max_capacity      = var.max_capacity
    capacity_provider_strategy = {
      fargate = {
        weight = var.fargate_weight
        base   = var.fargate_base
      }
      fargate_spot = one([
        for weight in [var.fargate_spot_weight] : {
          weight = weight
        }
        if weight != null
      ])
    }
    enable_execute_command = var.enable_execute_command
    log_retention_in_days  = var.log_retention_in_days
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
