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

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.gtw.id
  name        = "$default"
  auto_deploy = true
}
