locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = true
  }

  Name = "${var.project}-${var.environment}"

}
