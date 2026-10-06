variable "enable_nat_gateway" {
  type        = bool
  description = "NAT Gateway使用についての設定。"
  default     = true

  validation {
    condition     = var.enable_nat_gateway == true
    error_message = "本番環境のタスクはプライベートサブネットに置くため、外への出口としてNAT Gatewayが必要です。true にしてください。"
  }
}

variable "task_size" {
  type = object({
    cpu    = number
    memory = number
  })

  description = "Fargateのタスクサイズ。 タスク全体のメモリとCPUの組み合わせ。"

  default = {
    cpu    = 1024
    memory = 2048
  }

  validation {
    condition = anytrue([
      for size in [
        [1024, 2048],
        [2048, 4096],
      ] : var.task_size.cpu == size[0] && var.task_size.memory == size[1]
    ])
    error_message = <<-EOT
    本番環境では開発環境より大きいサイズだけ使えます。cpu と memory はセットで指定してください。

    - cpu = 1024, memory = 2048
    - cpu = 2048, memory = 4096
    EOT
  }
}

variable "image" {
  type        = string
  description = "コンテナのイメージURI。タグまで含める。"
  default     = "public.ecr.aws/docker/library/httpd:2.4"
}

variable "assign_public_ip" {
  type        = bool
  description = "タスクのENIにパブリックIPを割り当てるかどうかの設定。"
  default     = false

  validation {
    condition     = var.assign_public_ip == false
    error_message = "プライベートサブネットのタスクにパブリックIPは付けません。外への通信はNAT Gatewayを使ってください。false にしてください。"
  }
}

variable "use_public_subnet" {
  type        = bool
  description = "ECSサービスがpublicサブネットを使うかどうかの設定。"
  default     = false

  validation {
    condition     = var.use_public_subnet == false
    error_message = "本番環境のタスクはインターネットから直接届かないプライベートサブネットに置いてください。false にしてください。"
  }
}

variable "single_az" {
  type        = bool
  description = "ECSサービスを先頭のAZだけに置くかどうかの設定。"
  default     = false

  validation {
    condition     = var.single_az == false
    error_message = "可用性向上のため、複数のAZに置いてください。single_az は false にしてください。"
  }
}

variable "min_capacity" {
  type        = number
  description = "ECSサービスの最小タスク数。desired_countにも同じ値が使われる。"
  default     = 2

  validation {
    condition     = var.min_capacity == 2
    error_message = "可用性向上のため、最小タスク数は 2 にしてください。"
  }
}

variable "max_capacity" {
  type        = number
  description = "ECSサービスの最大タスク数。"
  default     = 4

  validation {
    condition     = var.max_capacity >= 2 && var.max_capacity <= 4
    error_message = "本番環境で増やせるタスクは 2 から 4 までです。最大タスク数をその範囲にしてください。"
  }
}

variable "fargate_weight" {
  type        = number
  description = "FARGATEキャパシティプロバイダのweight。比率であり、台数ではない。"
  default     = 1

  validation {
    condition     = var.fargate_weight == 1
    error_message = "本番環境のタスクは通常のFargateに置きます。weight は 1 にしてください。"
  }
}

variable "fargate_base" {
  type        = number
  description = "比率の前にFARGATEへ置く最低タスク数。未指定なら比率だけが使われる。"
  default     = 2

  validation {
    condition     = var.fargate_base == 2
    error_message = "最小の2台はSpotより先に通常のFargateへ置きます。base は 2 にしてください。"
  }
}

variable "fargate_spot_weight" {
  type        = number
  description = "FARGATE_SPOTのweight。nullのときはSpotを使わない。"
  default     = null

  validation {
    condition     = var.fargate_spot_weight == null
    error_message = "本番環境ではSpotを使用しません。null にしてください。"
  }
}

variable "enable_execute_command" {
  type        = bool
  description = "ECS Execでコンテナに入るかどうか。"
  default     = false

  validation {
    condition     = var.enable_execute_command == false
    error_message = "本番のコンテナにシェルで入れないようにしてください。false に設定してください。"
  }
}

variable "log_retention_in_days" {
  type        = number
  description = "コンテナログをCloudWatch Logsに残す日数。"
  default     = 30

  validation {
    condition     = contains([30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_in_days)
    error_message = "障害調査のため、ログは30日以上残してください。30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 のいずれかにしてください。"
  }
}

variable "instance_class" {
  type        = string
  description = "RDSのインスタンスクラス。"
  default     = "db.m7g.large"

  validation {
    condition     = contains(["db.m7g.large", "db.m7g.xlarge"], var.instance_class)
    error_message = "本番環境では負荷に耐えるDBだけ使えます。db.m7g.large または db.m7g.xlarge にしてください。"
  }
}

variable "allocated_storage" {
  type        = number
  description = "RDSのストレージ容量(GiB)。"
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 100
    error_message = "本番環境のストレージは 20 GiB 以上 100 GiB 以下にしてください。20 GiB は MySQL の最小サイズです。"
  }
}

variable "multi_az" {
  type        = bool
  description = "RDSをマルチAZにするかどうかの設定。"
  default     = true

  validation {
    condition     = var.multi_az == true
    error_message = "可用性向上のためマルチAZにしてください。true にしてください。"
  }
}

variable "enable_waf" {
  type        = bool
  description = "ALBにWAFを付けるかどうかの設定。"
  default     = true

  validation {
    condition     = var.enable_waf == true
    error_message = "本番環境ではインターネットからの不正なリクエストをWAFで止めます。true にしてください。"
  }
}

variable "enable_https" {
  type        = bool
  description = "ALBでHTTPSを受けるかどうかの設定。"
  default     = false
}

variable "domain_name" {
  type        = string
  description = "HTTPS証明書を発行するドメイン名。HTTPSを無効にするときはnull。"
  default     = null
}

variable "route53_zone_id" {
  type        = string
  description = "ドメインのレコードを作るRoute 53ゾーンID。HTTPSを無効にするときはnull。"
  default     = null
}
