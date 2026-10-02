variable "project_name" {
  type        = string
  description = "Prefix used for resource names in this stack."
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
  description = "VPC layout. Public, private, and database subnet lists must each match the length of azs. The ALB uses every public subnet, so at least two AZs are required."
}

variable "asg_config" {
  type = object({
    instance_type     = string
    min_size          = number
    max_size          = number
    desired_capacity  = number
    use_public_subnet = bool
    single_az         = bool
  })
  description = "Application capacity and placement. use_public_subnet selects public subnets. single_az keeps instances in the first of those subnets. instance_type must be x86_64 because the AMI is Amazon Linux 2023 x86_64."
}

variable "rds_config" {
  type = object({
    instance_class    = string
    allocated_storage = number
    multi_az          = bool
  })
  description = "RDS MySQL capacity. Engine, credentials, and deletion behavior stay inside the module."
}
