resource "aws_apigatewayv2_domain_name" "gtw" {
  domain_name = "gtw.${local.domain_name}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.gtw.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }


  depends_on = [
    time_sleep.wait_for_verification
  ]
}

resource "aws_apigatewayv2_api_mapping" "gtw_mapping" {
  api_id      = aws_apigatewayv2_api.gtw.id
  domain_name = aws_apigatewayv2_domain_name.gtw.domain_name
  stage       = aws_apigatewayv2_stage.default.name
}

resource "cloudflare_dns_record" "gtw_cname" {
  zone_id = local.aws_master_secrets["CLOUDFLARE_ZONE_ID"]
  name    = "gtw"
  type    = "CNAME"
  content = aws_apigatewayv2_domain_name.gtw.domain_name_configuration[0].target_domain_name
  ttl     = 1
  proxied = false
}
