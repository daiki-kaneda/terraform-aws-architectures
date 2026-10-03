locals {
  app_subnets = var.asg_config.use_public_subnet ? module.vpc.public_subnets : module.vpc.private_subnets
  asg_subnets = var.asg_config.single_az ? [local.app_subnets[0]] : local.app_subnets
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = var.project_name

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

  image_id        = data.aws_ssm_parameter.amazon_linux.value
  instance_type   = var.asg_config.instance_type
  security_groups = [module.app_sg.id]
  user_data = base64encode(<<-EOT
    #!/bin/bash
    dnf install -y httpd
    systemctl enable --now httpd
    echo ok > /var/www/html/index.html
  EOT
  )

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
