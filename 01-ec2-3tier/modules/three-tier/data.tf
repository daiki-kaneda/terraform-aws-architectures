data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_region" "current" {

}

data "aws_availability_zones" "available" {
  state = "available"

  lifecycle {
    postcondition {
      condition = alltrue(
        [for az in var.vpc_config.azs : contains(
          self.names, az
        )]
      )
      error_message = <<-EOT
      少なくとも一つのVPCのAZが有効ではありません。
      以下が"${data.aws_region.current.region}"で有効なAZです。
      
      [${join(", ", self.names)}]
      EOT
    }
  }
}