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
      vpc_config.azs に、${data.aws_region.current.region} で使えないAZがあります。次の名前から選んでください。

      ${join(", ", self.names)}
      EOT
    }
  }
}