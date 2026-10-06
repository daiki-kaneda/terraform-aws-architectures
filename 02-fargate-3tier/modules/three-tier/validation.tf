resource "terraform_data" "nat_config" {
  lifecycle {
    precondition {
      condition     = var.vpc_config.enable_nat_gateway || var.fargate_config.use_public_subnet
      error_message = "NAT Gatewayが無効である状態で、ECSサービスがprivateサブネットを使用しています。"
    }

    precondition {
      condition     = !(var.vpc_config.enable_nat_gateway && var.fargate_config.use_public_subnet)
      error_message = "ECSサービスがpublicサブネットを使用している状態で、NAT Gatewayが有効になっています。"
    }

    precondition {
      condition     = !var.fargate_config.use_public_subnet || var.fargate_config.assign_public_ip
      error_message = "ECSサービスがpublicサブネットを使用している状態で、パブリックIPが割り当てられていません。"
    }

    precondition {
      condition     = var.fargate_config.use_public_subnet || !var.fargate_config.assign_public_ip
      error_message = "ECSサービスがprivateサブネットを使用している状態で、パブリックIPが割り当てられています。"
    }
  }
}