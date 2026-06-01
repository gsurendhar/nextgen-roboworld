# ACM certificate
resource "aws_acm_certificate" "gonela" {
  domain_name       = "*.gonela.site"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "gonela" {
  for_each = {
    for dvo in aws_acm_certificate.gonela.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.zone_ids
}

# resource "aws_acm_certificate_validation" "gonela" {
#   certificate_arn         = aws_acm_certificate.gonela.arn
#   validation_record_fqdns = [for record in aws_route53_record.gonela : record.fqdn]
# }

resource "aws_acm_certificate_validation" "gonela" {
  certificate_arn         = aws_acm_certificate.gonela.arn
  validation_record_fqdns = [for record in aws_route53_record.gonela : record.fqdn]
  depends_on = [aws_route53_record.gonela]
}

# Create a Route 53 Hosted Zone
resource "aws_route53_zone" "my_zone" {
  name = "gonela.site" # Replace with your domain name
}


#outputs of hosted zone name servers
output "name_servers" {
  value = data.aws_route53_zone.selected.name_servers
}