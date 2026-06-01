data "aws_ssm_parameter" "vpc_id" {
    name = "/${var.project}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "ingress_alb_sg_id"{
  name = "/${var.project}/${var.environment}/ingress_alb_sg_id"
}

data "aws_ssm_parameter" "private_subnet_ids"{
  name = "/${var.project}/${var.environment}/private_subnet_ids"
}

data "aws_ssm_parameter" "public_subnet_ids"{
  name = "/${var.project}/${var.environment}/public_subnet_ids"
}

data "aws_ssm_parameter" "acm_certificate_arn"{
  name = "/${var.project}/${var.environment}/acm_certificate_arn"
}


data "aws_route53_zone" "selected" {
  name         = "gonela.site" # Replace with your domain name
  # or
  # zone_id = aws_route53_zone.my_zone.id           #"Z2FDTNDUVT1FRY"  Replace with your hosted zone ID
}