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

variable "fargate_config" {
  type = object({
    cpu               = number
    memory            = number
    image             = string
    assign_public_ip  = bool
    use_public_subnet = bool
    single_az         = bool
    min_capacity      = number
    max_capacity      = number
    capacity_provider_strategy = object({
      fargate = object({
        weight = number
        base   = optional(number)
      })
      fargate_spot = optional(object({
        weight = number
      }))
    })
    enable_execute_command = bool
    log_retention_in_days  = number
  })
  description = <<-EOT
  Fargateタスクのサイズ、台数、配置、キャパシティプロバイダの配分。
  cpuとmemoryはタスク全体のサイズで、料金はここで決まります。
  capacity_provider_strategyのbaseを書けるのはFARGATE側だけです。weightは比率です。
  EOT

  validation {
    condition = (
      var.fargate_config.cpu == 256 && contains([512, 1024, 2048], var.fargate_config.memory)
      ) || (
      var.fargate_config.cpu == 512 && contains([1024, 2048, 3072, 4096], var.fargate_config.memory)
      ) || (
      var.fargate_config.cpu == 1024 && contains(range(2048, 8193, 1024), var.fargate_config.memory)
      ) || (
      var.fargate_config.cpu == 2048 && contains(range(4096, 16385, 1024), var.fargate_config.memory)
      ) || (
      var.fargate_config.cpu == 4096 && contains(range(8192, 30721, 1024), var.fargate_config.memory)
      ) || (
      var.fargate_config.cpu == 8192 && contains(range(16384, 61441, 4096), var.fargate_config.memory)
      ) || (
      var.fargate_config.cpu == 16384 && contains(range(32768, 122881, 8192), var.fargate_config.memory)
    )
    error_message = "cpuとmemoryはFargateが許可する組み合わせにしてください。"
  }

  validation {
    condition     = length(var.fargate_config.image) > 0
    error_message = "コンテナイメージのURIを指定してください。"
  }

  validation {
    condition = (
      var.fargate_config.min_capacity >= 1 &&
      var.fargate_config.max_capacity >= var.fargate_config.min_capacity
    )
    error_message = "最小台数は1以上、最大台数は最小台数以上にしてください。"
  }

  validation {
    condition = (
      var.fargate_config.capacity_provider_strategy.fargate.weight >= 0 &&
      (
        var.fargate_config.capacity_provider_strategy.fargate_spot == null ||
        var.fargate_config.capacity_provider_strategy.fargate_spot.weight >= 0
      ) &&
      (
        var.fargate_config.capacity_provider_strategy.fargate.weight > 0 ||
        try(var.fargate_config.capacity_provider_strategy.fargate_spot.weight, 0) > 0
      )
    )
    error_message = "キャパシティプロバイダのweightは0以上で、少なくとも一方は1以上にしてください。"
  }

  validation {
    condition     = try(var.fargate_config.capacity_provider_strategy.fargate.base, 0) >= 0
    error_message = "FARGATEのbaseは0以上にしてください。"
  }

  validation {
    condition = contains(
      [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653],
      var.fargate_config.log_retention_in_days
    )
    error_message = "ログの保持日数はCloudWatch Logsが受け付ける値にしてください。"
  }
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
    error_message = "HTTPSが有効にした場合、ドメイン名とRoute53ゾーンIDは必須です。"
  }
}
