variable "enable_nat_gateway" {
  type        = bool
  description = "NAT Gateway使用についての設定。"
  default     = false

  validation {
    condition     = var.enable_nat_gateway == false
    error_message = "開発環境ではNAT Gatewayの料金を避けるため、使えません。false にしてください。"
  }
}

variable "task_size" {
  type = object({
    cpu    = number
    memory = number
  })

  description = "Fargateのタスクサイズ。 タスク全体のメモリとCPUの組み合わせ。"

  default = {
    cpu    = 256
    memory = 512
  }

  validation {
    condition = anytrue([
      for size in [
        [256, 512],
        [512, 1024],
      ] : var.task_size.cpu == size[0] && var.task_size.memory == size[1]
    ])
    error_message = <<-EOT
    開発環境では料金を抑えるため、次の組み合わせだけ使えます。cpu と memory はセットで指定してください。

    - cpu = 256, memory = 512
    - cpu = 512, memory = 1024
    EOT
  }
}


variable "assign_public_ip" {
  type        = bool
  description = "タスクのENIにパブリックIPを割り当てるかどうかの設定。"
  default     = true
  validation {
    condition     = var.assign_public_ip == true
    error_message = "パブリックサブネットのタスクは、パブリックIPがないとインターネットへ出られません。true にしてください。"
  }
}

variable "use_public_subnet" {
  type        = bool
  description = "ECSサービスがpublicサブネットを使うかどうかの設定。"
  default     = true

  validation {
    condition     = var.use_public_subnet
    error_message = "NAT Gatewayがないため、プライベートサブネットからはインターネットへ出られません。ECSサービスはパブリックサブネットに置いてください。"
  }
}

variable "single_az" {
  type        = bool
  description = "ECSサービスを先頭のAZだけに置くかどうかの設定。"
  default     = true

  validation {
    condition     = var.single_az
    error_message = "開発環境ではAZを1つに抑え、構成と料金を小さくしています。true にしてください。"
  }
}

variable "min_capacity" {
  type        = number
  description = "ECSサービスの最小タスク数。desired_countにも同じ値が使われる。"
  default     = 0
  validation {
    condition     = var.min_capacity == 0
    error_message = "使っていないときはタスクを止めて料金がかからないようにします。最小タスク数は 0 にしてください。"
  }
}

variable "max_capacity" {
  type        = number
  description = "ECSサービスの最大タスク数。"
  default     = 1
  validation {
    condition     = var.max_capacity == 1
    error_message = "開発環境で同時に動かすタスクは1台までです。最大タスク数は 1 にしてください。"
  }
}

variable "fargate_weight" {
  type        = number
  description = "FARGATEキャパシティプロバイダのweight。比率であり、台数ではない。"
  default     = 0

  validation {
    condition     = var.fargate_weight == 0
    error_message = "開発環境のタスクはFargate Spotに置きます。通常のFargateのweightは 0 にしてください。"
  }
}

variable "fargate_base" {
  type        = number
  description = "比率の前にFARGATEへ置く最低タスク数。未指定なら比率だけが使われる。"
  default     = 0

  validation {
    condition     = var.fargate_base == 0
    error_message = "baseは通常のFargateに先に置くタスク数です。1以上にすると、Spotより先に通常料金のタスクが起動します。0 にしてください。"
  }
}

variable "fargate_spot_weight" {
  type        = number
  description = "FARGATE_SPOTのweight。nullのときはSpotを使わない。"
  default     = 1

  validation {
    condition     = var.fargate_spot_weight == 1
    error_message = "開発環境ではFargate Spotだけを使います。Spotのweightは 1 にしてください。"
  }
}

variable "enable_execute_command" {
  type        = bool
  description = "ECS Execでコンテナに入るかどうか。"
  default     = true

  validation {
    condition     = var.enable_execute_command
    error_message = "コンテナの中を確認できるよう、ECS Execは有効にしてください。"
  }
}

variable "log_retention_in_days" {
  type        = number
  description = "コンテナログをCloudWatch Logsに残す日数。"
  default     = 7

  validation {
    condition     = var.log_retention_in_days == 7
    error_message = "ログの保管料金を抑えるため、保持日数は 7 日にしてください。"
  }
}

variable "instance_class" {
  type        = string
  description = "RDSのインスタンスクラス。"
  default     = "db.t4g.micro"

  validation {
    condition     = contains(["db.t4g.micro", "db.t3.micro"], var.instance_class)
    error_message = "開発環境では小さいDBだけ使えます。db.t4g.micro または db.t3.micro にしてください。"
  }
}

variable "allocated_storage" {
  type        = number
  description = "RDSのストレージ容量(GiB)。"
  default     = 20

  validation {
    condition     = var.allocated_storage == 20
    error_message = "開発環境のストレージはMySQLの最小サイズに固定しています。20 にしてください。"
  }
}

variable "multi_az" {
  type        = bool
  description = "RDSをマルチAZにするかどうかの設定。"
  default     = false

  validation {
    condition     = var.multi_az == false
    error_message = "スタンバイ用DBの料金がかかるため、開発環境ではマルチAZにできません。false にしてください。"
  }
}

variable "enable_waf" {
  type    = bool
  default = false
  validation {
    condition     = var.enable_waf == false
    error_message = "開発環境ではWAFの料金を避けるため、無効にしてください。"
  }
}

variable "enable_https" {
  type    = bool
  default = false
  validation {
    condition     = var.enable_https == false
    error_message = "開発環境では証明書と独自ドメインを使わないため、HTTPSは無効にしてください。"
  }
}
