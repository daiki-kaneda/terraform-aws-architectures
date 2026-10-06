resource "terraform_data" "nat_config" {
  lifecycle {
    precondition {
      condition     = var.vpc_config.enable_nat_gateway || var.fargate_config.use_public_subnet
      error_message = "NAT Gatewayが無効なのに、ECSサービスがプライベートサブネットにあります。このままだとタスクからインターネットへ出られません。NAT Gatewayを有効にするか、パブリックサブネットを使ってください。"
    }

    precondition {
      condition     = !(var.vpc_config.enable_nat_gateway && var.fargate_config.use_public_subnet)
      error_message = "パブリックサブネットを使っているのにNAT Gatewayが有効です。外への出口が二重になり、NATの料金だけ増えます。NAT Gatewayを無効にするか、プライベートサブネットを使ってください。"
    }

    precondition {
      condition     = !var.fargate_config.use_public_subnet || var.fargate_config.assign_public_ip
      error_message = "パブリックサブネットのタスクにパブリックIPがありません。イメージの取得や外への通信ができません。assign_public_ip を true にしてください。"
    }

    precondition {
      condition     = var.fargate_config.use_public_subnet || !var.fargate_config.assign_public_ip
      error_message = "プライベートサブネットのタスクにパブリックIPが割り当てられています。外への通信はNAT Gatewayを使うので、assign_public_ip は false にしてください。"
    }
  }
}