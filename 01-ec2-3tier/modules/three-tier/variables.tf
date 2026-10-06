variable "project_name" {
  type        = string
  description = "リソース名の接頭語として使われるプロジェクト名"
}

variable "vpc_config" {
  type = object({
    cidr               = string
    azs                = list(string)
    public_subnets     = list(string)
    private_subnets    = list(string)
    database_subnets   = list(string)
    enable_nat_gateway = bool
  })
  description = <<-EOT
  VPCの設定. パブリック、プライベート、データベースのサブネットの数はAZのサブネットの個数と一致していなければいけません。
  少なくとも二つのAZが必要です。
  EOT

  validation {
    condition     = can(cidrnetmask(var.vpc_config["cidr"]))
    error_message = "VPCのCIDRがIPv4のCIDRではありません。10.0.0.0/16 のように指定してください。"
  }

  validation {
    condition = alltrue([
      for cidr in var.vpc_config["public_subnets"] : can(cidrnetmask(cidr))
    ])
    error_message = "パブリックサブネットに、IPv4のCIDRではない値があります。10.0.101.0/24 のように指定してください。"
  }

  validation {
    condition = alltrue([
      for cidr in var.vpc_config["private_subnets"] : can(cidrnetmask(cidr))
    ])
    error_message = "プライベートサブネットに、IPv4のCIDRではない値があります。10.0.1.0/24 のように指定してください。"
  }

  validation {
    condition = alltrue([
      for cidr in var.vpc_config["database_subnets"] : can(cidrnetmask(cidr))
    ])
    error_message = "データベースサブネットに、IPv4のCIDRではない値があります。10.0.201.0/24 のように指定してください。"
  }
}

variable "asg_config" {
  type = object({
    instance_type     = string
    min_size          = number
    max_size          = number
    desired_capacity  = number
    use_public_subnet = bool
    single_az         = bool
  })
  description = <<-EOT
  インスタンスのキャパシティと配置の設定。
  use_public_subnetはパブリックサブネットを使用します。
  single_azはサブネットのリストの最初のサブネットのみを使用します。
  インスタンスタイプはAMIがAmazon Linux 2023 x86_64のため、x86_64でなければいけません。
  EOT
}

variable "rds_config" {
  type = object({
    instance_class    = string
    allocated_storage = number
    multi_az          = bool
  })
  description = <<-EOT
  RDS MySQLについての設定。インスタンスクラス、ストレージ、マルチAZのせ
  EOT
}

variable "alb_config" {
  type = object({
    enable_https    = bool
    domain_name     = optional(string)
    route53_zone_id = optional(string)
    enable_waf      = bool
  })

  validation {
    condition = !var.alb_config.enable_https || (
      var.alb_config.domain_name != null && var.alb_config.route53_zone_id != null
    )
    error_message = "HTTPSを有効にしたときは、証明書を出すドメイン名と、そのレコードを作るRoute 53ゾーンIDの両方が必要です。"
  }
}
