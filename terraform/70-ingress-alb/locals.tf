locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  private_subnet_ids  = split("," , data.aws_ssm_parameter.private_subnet_ids.value)
  public_subnet_ids  = split("," , data.aws_ssm_parameter.public_subnet_ids.value)
  ingress_alb_sg_id  = data.aws_ssm_parameter.ingress_alb_sg_id.value
  acm_certificate_arn = data.aws_ssm_parameter.acm_certificate_arn.value

  common_tags = {
      Project      = var.project
      Environment  = var.environment
      Terraform    = true
  }

  Name = "${var.project}-${var.environment}"

  zone_name = data.aws_route53_zone.selected.name
  zone_id = data.aws_route53_zone.selected.zone_id
}