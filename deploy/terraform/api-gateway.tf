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

resource "aws_apigatewayv2_domain_name" "api_domain" {
  domain_name = "gtw.frameify.dev"

  domain_name_configuration {
    certificate_arn = data.aws_acm_certificate.api_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.gtw.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_apigatewayv2_api.gtw.id
  domain_name = aws_apigatewayv2_domain_name.api_domain.domain_name
  stage       = aws_apigatewayv2_stage.default.name
}

output "api_endpoint" {
  value = aws_apigatewayv2_stage.default.invoke_url
}

output "api_domain_name" {
  value = aws_apigatewayv2_domain_name.api_domain.domain_name
}
