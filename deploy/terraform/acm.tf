# AWS ACM Certificate for Subdomain gtw.<domain_name> with DNS Validation via Cloudflare
resource "aws_acm_certificate" "gtw" {
  domain_name       = "gtw.${local.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_dns_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.gtw.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      value = dvo.resource_record_value
      type  = dvo.resource_record_type
    }
  }

  zone_id = local.aws_master_secrets["CLOUDFLARE_ZONE_ID"]
  name    = each.value.name
  content = each.value.value
  type    = each.value.type
  ttl     = 60
  proxied = false
}

# 10. Aguardar verificação do domínio (local-exec opcional)
resource "time_sleep" "wait_for_verification" {
  depends_on = [
    cloudflare_dns_record.acm_validation,
  ]
  create_duration = "60s"
}

# AWS ACM Certificate for Subdomain <domain_name> with DNS Validation via Cloudflare
resource "aws_acm_certificate" "front" {

  domain_name       = local.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_dns_record" "front_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.front.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      value = dvo.resource_record_value
      type  = dvo.resource_record_type
    }
  }

  zone_id = local.aws_master_secrets["CLOUDFLARE_ZONE_ID"]
  name    = each.value.name
  content = each.value.value
  type    = each.value.type
  ttl     = 60
  proxied = false
}
