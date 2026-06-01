# data "aws_ssm_parameter" "zone_id" {
#   name = "/${var.project}/${var.environment}/zone_id"
# }



data "aws_route53_zone" "selected" {
  # name         = "gonela.site" # Replace with your domain name
  # or
  zone_id = aws_route53_zone.my_zone.id           #"Z2FDTNDUVT1FRY"  Replace with your hosted zone ID
}