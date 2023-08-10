# create route 53 hosted zone
data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

# create a record for the production enveronment
resource "aws_route53_record" "k8s_A_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.prod_domain_name
  type    = "A"

alias {
    name                   = var.prod-lb-dns-name
    zone_id                = var.prod-lb-zone-id
    evaluate_target_health = true
  }
 }

# Create a record for the stage enveronment
resource "aws_route53_record" "stage_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.stage_domain_hosted_zone
  type    = "A"

alias {
    name                   = var.stage-lb-dns-name
    zone_id                = var.stage-lb-zone-id
    evaluate_target_health = true
  }

}

# create a record for promethus service 
resource "aws_route53_record" "prometheus_record" {
  zone_id = data.aws_route53_zone.selected.zone_id 
  name    = var.prometheus_domain_hosted_zone
  type    = "A"

alias {
    name                   = var.prometheus-lb-dns-name
    zone_id                = var.prometheus-lb-zone-id
    evaluate_target_health = true
}

}

# create a record for grafana service
resource "aws_route53_record" "grafana_record" {
  zone_id = data.aws_route53_zone.selected.zone_id 
  name    = var.grafana_domain_hosted_zone
  type    = "A"

alias {
    name                   = var.grafana-lb-dns-name
    zone_id                = var.grafana-lb-zone-id
    evaluate_target_health = true
}

}

# create certificate that depend on having a domain name
resource "aws_acm_certificate" "k8s-cert" {
  domain_name       = var.domain_name
  subject_alternative_names = [var.domain_name2]
  validation_method = "DNS"

  tags = {
    Environment = "production"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# attaching route53 and the certificate- connecting route53 to the certificate
resource "aws_route53_record" "k8s-project" {
  for_each = {
    for anybody in aws_acm_certificate.k8s-cert.domain_validation_options : anybody.domain_name => {
      name   = anybody.resource_record_name
      record = anybody.resource_record_value
      type   = anybody.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

# sign the certificate
resource "aws_acm_certificate_validation" "sign_cert" {
  certificate_arn         = aws_acm_certificate.k8s-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.k8s-project : record.fqdn]
}

# Route53 and Records 
data "aws_route53_zone" "ssl-certf" {
  name         = var.domain_name
  private_zone = false
}

#  Create ACM Certificate
resource "aws_acm_certificate" "acm_certificate" {
  domain_name       = var.domain_name
  subject_alternative_names = [var.domain_name2]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# Create route53 validation record
resource "aws_route53_record" "validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.ssl-certf.zone_id
}

# Create acm certificate validition
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_record : record.fqdn]
}