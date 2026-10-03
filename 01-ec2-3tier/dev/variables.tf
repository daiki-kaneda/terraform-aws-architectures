variable "enable_nat_gateway" {
  type        = bool
  description = "NAT Gateway使用についての設定。"
  default     = false

  validation {
    condition     = var.enable_nat_gateway == false
    error_message = "開発環境ではNAT Gatewayを使用できません。"
  }
}

variable "instance_type" {
  type        = string
  description = "ASGのインスタンスタイプ。AMIがAmazon Linux 2023 x86_64のため、x86_64のmicroのみ。"
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3a.micro"], var.instance_type)
    error_message = "開発環境のインスタンスタイプは t3.micro または t3a.micro にしてください。"
  }
}

variable "min_size" {
  type        = number
  description = "ASGの最小キャパシティ。"
  default     = 1

  validation {
    condition     = var.min_size == 1
    error_message = "開発環境のASGの最小キャパシティは1にしてください。"
  }
}

variable "max_size" {
  type        = number
  description = "ASGの最大キャパシティ。"
  default     = 1

  validation {
    condition     = var.max_size == 1
    error_message = "開発環境のASGの最大キャパシティは1にしてください。"
  }
}

variable "desired_capacity" {
  type        = number
  description = "ASGの希望するキャパシティ。"
  default     = 1

  validation {
    condition     = var.desired_capacity == 1
    error_message = "開発環境のASGの希望するキャパシティは1にしてください。"
  }
}

variable "use_public_subnet" {
  type        = bool
  description = "ASGがpublicサブネットを使うかどうかの設定。"
  default     = true

  validation {
    condition     = var.use_public_subnet
    error_message = "開発環境ではNAT Gatewayを使わないため、ASGではpublicサブネットを使用してください。"
  }
}

variable "single_az" {
  type        = bool
  description = "ASGを先頭のAZだけに置くかどうかの設定。"
  default     = true

  validation {
    condition     = var.single_az
    error_message = "開発環境では、ASGのAZは1つだけにしてください。"
  }
}

variable "instance_class" {
  type        = string
  description = "RDSのインスタンスクラス。"
  default     = "db.t4g.micro"

  validation {
    condition     = contains(["db.t4g.micro", "db.t3.micro"], var.instance_class)
    error_message = "開発環境のRDSインスタンスクラスは db.t4g.micro または db.t3.micro にしてください。"
  }
}

variable "allocated_storage" {
  type        = number
  description = "RDSのストレージ容量(GiB)。"
  default     = 20

  validation {
    condition     = var.allocated_storage == 20
    error_message = "開発環境のRDSストレージはMySQLのストレージの下限である20GiBにしてください。"
  }
}

variable "multi_az" {
  type        = bool
  description = "RDSをマルチAZにするかどうかの設定。"
  default     = false

  validation {
    condition     = var.multi_az == false
    error_message = "開発環境ではRDSのマルチAZは使えません。"
  }
}

variable "enable_waf" {
  type    = bool
  default = false
  validation {
    condition     = var.enable_waf == false
    error_message = "開発環境ではWAFは無効にします。"
  }
}

variable "enable_https" {
  type    = bool
  default = false
  validation {
    condition     = var.enable_https == false
    error_message = "開発環境ではHTTPSを無効にします。"
  }
}
