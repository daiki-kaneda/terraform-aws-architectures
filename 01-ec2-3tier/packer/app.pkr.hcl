packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type = string
}

variable "git_sha" {
  type = string
}

variable "run_id" {
  type = string
}

variable "subnet_id" {
  type    = string
  default = ""
}

locals {
  subnet_id = var.subnet_id != "" ? var.subnet_id : null
}

# https://developer.hashicorp.com/packer/integrations/hashicorp/amazon/latest/components/builder/ebs
source "amazon-ebs" "app" {
  ami_name                    = "ec2-3tier-${var.git_sha}-${var.run_id}"
  instance_type               = "t3.micro"
  region                      = var.region
  ssh_username                = "ec2-user"
  ssh_timeout                 = "10m"
  subnet_id                   = local.subnet_id
  associate_public_ip_address = true

  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-kernel-*-x86_64"
      architecture        = "x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }

  tags = {
    Name    = "ec2-3tier-${var.git_sha}"
    Project = "ec2-3tier"
    GitSha  = var.git_sha
  }

  snapshot_tags = {
    Project = "ec2-3tier"
    GitSha  = var.git_sha
  }
}

build {
  sources = ["source.amazon-ebs.app"]

  # https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner
  provisioner "shell" {
    inline = ["mkdir -p /tmp/app-src"]
  }

  provisioner "file" {
    source      = "../app/app"
    destination = "/tmp/app-src"
  }

  provisioner "file" {
    source      = "../app/requirements.txt"
    destination = "/tmp/app-src/requirements.txt"
  }

  provisioner "file" {
    source      = "app.service"
    destination = "/tmp/app-src/app.service"
  }

  provisioner "shell" {
    script          = "scripts/install.sh"
    execute_command = "sudo bash '{{ .Path }}'"
  }

  # https://developer.hashicorp.com/packer/docs/post-processors/manifest
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
