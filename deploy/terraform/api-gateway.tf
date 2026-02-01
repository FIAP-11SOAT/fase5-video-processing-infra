
resource "aws_apigatewayv2_api" "gtw" {
  name          = "${var.project_name}-api-gateway"
  protocol_type = "HTTP"
  cors_configuration {
    allow_headers = ["*"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  tags = {
    Name = "${var.project_name}-api-gateway"
  }
}

resource "aws_apigatewayv2_domain_name" "gtw_custom_domain" {
  domain_name = "gtw.frameify.dev"

  domain_name_configuration {
    certificate_arn = data.aws_acm_certificate.domain_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "cloudflare_dns_record" "cloudflare_gtw_domain" {
  zone_id = local.clean_image_repo_url["CLOUDFLARE_ZONE_ID"]
  comment = "Subdomain for API Gateway"
  name    = "gtw"
  type    = "CNAME"
  content = aws_apigatewayv2_domain_name.gtw_custom_domain.domain_name
  ttl     = 1
  proxied = false
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.gtw.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_apigatewayv2_api.gtw.id
  domain_name = aws_apigatewayv2_domain_name.gtw_custom_domain.domain_name
  stage       = aws_apigatewayv2_stage.default.name
}

output "api_endpoint" {
  value = aws_apigatewayv2_stage.default.invoke_url
}

output "api_domain_name" {
  value = aws_apigatewayv2_domain_name.gtw_custom_domain.domain_name
}
