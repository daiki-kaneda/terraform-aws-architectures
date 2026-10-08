locals {
  app_subnets = var.asg_config.use_public_subnet ? module.vpc.public_subnets : module.vpc.private_subnets
  asg_subnets = var.asg_config.single_az ? [local.app_subnets[0]] : local.app_subnets
}

# 初期値は Amazon Linux 2023。アプリCDが Packer の AMI ID で上書きする。
# value を apply で戻すと、動いているアプリが初期AMIに戻る。
resource "aws_ssm_parameter" "app_ami" {
  name        = "/${var.project_name}/app-ami"
  description = "ASGが起動するアプリAMIのID。初期値はAmazon Linux 2023。"
  type        = "String"
  data_type   = "aws:ec2:image"
  value       = data.aws_ssm_parameter.amazon_linux.value

  lifecycle {
    # https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#ignore_changes
    ignore_changes = [value]
  }
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # CDがグループ名を指定して instance refresh する。
  # https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
  name            = var.project_name
  use_name_prefix = false

  min_size                  = var.asg_config.min_size
  max_size                  = var.asg_config.max_size
  desired_capacity          = var.asg_config.desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = local.asg_subnets

  traffic_source_attachments = {
    alb = {
      traffic_source_identifier = module.alb.target_groups["app"].arn
      traffic_source_type       = "elbv2"
    }
  }

  # 起動のたびにパラメータの最新AMIを解決する。テンプレート自体は変えない。
  # https://docs.aws.amazon.com/autoscaling/ec2/userguide/using-systems-manager-parameters.html
  image_id        = "resolve:ssm:${aws_ssm_parameter.app_ami.name}"
  instance_type   = var.asg_config.instance_type
  security_groups = [module.app_sg.id]

  create_iam_instance_profile = true
  iam_role_name               = "${var.project_name}-ec2"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}
