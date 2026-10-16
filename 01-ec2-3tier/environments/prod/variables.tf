variable "enable_nat_gateway" {
  type        = bool
  description = "NAT Gateway使用についての設定。"
  default     = true

  validation {
    condition     = var.enable_nat_gateway == true
    error_message = "本番環境のインスタンスはプライベートサブネットに置くため、外への出口としてNAT Gatewayが必要です。true にしてください。"
  }
}

variable "instance_type" {
  type        = string
  description = "ASGのインスタンスタイプ。 x86_64使用。"
  default     = "m7i.large"

  validation {
    condition     = contains(["m7i.large", "m7i.xlarge"], var.instance_type)
    error_message = "本番環境では負荷に耐えるサイズだけ使えます。m7i.large または m7i.xlarge にしてください。"
  }
}

variable "min_size" {
  type        = number
  description = "ASGの最小キャパシティ。"
  default     = 2

  validation {
    condition     = var.min_size == 2
    error_message = "1台が止まってもサービスを続けるため、最小台数は 2 にしてください。"
  }
}

variable "max_size" {
  type        = number
  description = "ASGの最大キャパシティ。"
  default     = 2

  validation {
    condition     = var.max_size >= 2 && var.max_size <= 4
    error_message = "本番環境で増やせる台数は 2 から 4 までです。最大台数をその範囲にしてください。"
  }
}

variable "desired_capacity" {
  type        = number
  description = "ASGの希望するキャパシティ。"
  default     = 2

  validation {
    condition     = var.desired_capacity == 2
    error_message = "平常時は2台で動かします。希望する台数は 2 にしてください。"
  }
}

variable "use_public_subnet" {
  type        = bool
  description = "ASGがpublicサブネットを使うかどうかの設定。"
  default     = false

  validation {
    condition     = var.use_public_subnet == false
    error_message = "本番環境のインスタンスはインターネットから直接届かないプライベートサブネットに置いてください。false にしてください。"
  }
}

variable "single_az" {
  type        = bool
  description = "ASGを先頭のAZだけに置くかどうかの設定。"
  default     = false

  validation {
    condition     = var.single_az == false
    error_message = "1つのAZが止まってもサービスを続けるため、複数のAZに置いてください。single_az は false にしてください。"
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
    error_message = "DBの片方が止まっても継続できるよう、マルチAZにしてください。true にしてください。"
  }
}

variable "enable_waf" {
  type    = bool
  default = true
  validation {
    condition     = var.enable_waf == true
    error_message = "本番環境ではインターネットからの不正なリクエストをWAFで止めます。true にしてください。"
  }
}

variable "enable_https" {
  type    = bool
  default = false
}

variable "domain_name" {
  type    = string
  default = null
}
variable "route53_zone_id" {
  type    = string
  default = null
}
