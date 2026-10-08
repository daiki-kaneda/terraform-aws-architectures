locals {
  app_subnets     = var.fargate_config.use_public_subnet ? module.vpc.public_subnets : module.vpc.private_subnets
  service_subnets = var.fargate_config.single_az ? [local.app_subnets[0]] : local.app_subnets

  capacity_provider_strategy = merge(
    {
      FARGATE = {
        capacity_provider = "FARGATE"
        weight            = var.fargate_config.capacity_provider_strategy.fargate.weight
        base              = var.fargate_config.capacity_provider_strategy.fargate.base
      }
    },
    {
      for name, strategy in {
        FARGATE_SPOT = var.fargate_config.capacity_provider_strategy.fargate_spot
        } : name => {
        capacity_provider = name
        weight            = strategy.weight
      } if strategy != null
    }
  )

  container_name  = "app"
  container_port  = 80
  bootstrap_image = "public.ecr.aws/docker/library/httpd:2.4"
}

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 7.0"

  name = "${var.project_name}-cluster"

  cluster_capacity_providers = concat(
    ["FARGATE"],
    var.fargate_config.capacity_provider_strategy.fargate_spot != null ? ["FARGATE_SPOT"] : []
  )
}

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 7.0"

  name        = "${var.project_name}-service"
  cluster_arn = module.ecs_cluster.arn

  # 作成後に変えるとサービスが作り直しになる。アプリCDがタスク定義を更新するため、最初から有効にする。
  # https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/service
  ignore_task_definition_changes = true

  cpu    = var.fargate_config.cpu
  memory = var.fargate_config.memory

  capacity_provider_strategy = local.capacity_provider_strategy

  desired_count            = var.fargate_config.min_capacity
  enable_autoscaling       = true
  autoscaling_min_capacity = var.fargate_config.min_capacity
  autoscaling_max_capacity = var.fargate_config.max_capacity

  enable_execute_command = var.fargate_config.enable_execute_command
  assign_public_ip       = var.fargate_config.assign_public_ip

  container_definitions = {
    (local.container_name) = {
      image = local.bootstrap_image
      portMappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          protocol      = "tcp"
        }
      ]
      readonlyRootFilesystem                 = false
      cloudwatch_log_group_retention_in_days = var.fargate_config.log_retention_in_days
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["app"].arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = local.service_subnets
  security_group_ingress_rules = {
    http = {
      description                  = "HTTP from the load balancer"
      from_port                    = local.container_port
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.alb.security_group_id
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

