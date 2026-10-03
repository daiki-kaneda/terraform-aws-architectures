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
    error_message = "VPCのCIDRブロックが無効な値です。"
  }

  validation {
    condition = alltrue([
      for cidr in var.vpc_config["public_subnets"] : can(cidrnetmask(cidr))
    ])
    error_message = "パブリックサブネットの少なくともひとつのCIDRブロックが無効な値です。"
  }

  validation {
    condition = alltrue([
      for cidr in var.vpc_config["private_subnets"] : can(cidrnetmask(cidr))
    ])
    error_message = "プライベートサブネットの少なくともひとつのCIDRブロックが無効な値です。"
  }

  validation {
    condition = alltrue([
      for cidr in var.vpc_config["database_subnets"] : can(cidrnetmask(cidr))
    ])
    error_message = "データベースのサブネットの少なくともひとつのCIDRブロックが無効な値です。"
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
