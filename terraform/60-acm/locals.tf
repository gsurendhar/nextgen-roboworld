locals {
  # zone_id                  = data.aws_ssm_parameter.zone_id.value

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = true
  }

  Name        = "${var.project}-${var.environment}"
  zone_name   = data.aws_route53_zone.selected.name
  zone_ids    = data.aws_route53_zone.selected.zone_id

}