resource "aws_secretsmanager_secret" "secrets" {
  name                    = "${var.project_name}-secrets"
  description             = "Secrets for ${var.project_name} project"
  recovery_window_in_days = 0

  tags = {
    Name = "${var.project_name}-secrets"
  }
}


resource "aws_secretsmanager_secret_version" "secrets" {
  secret_id = aws_secretsmanager_secret.secrets.id
  secret_string = jsonencode({
    # VPC_ID = module.vpc.vpc_id,
    GTW_ID = aws_apigatewayv2_api.gtw.id,
    GTW_ENDPOINT = aws_apigatewayv2_stage.default.invoke_url,
    COGNITO_USER_POOL_ID        = aws_cognito_user_pool.this.id,
    COGNITO_USER_POOL_CLIENT_ID = aws_cognito_user_pool_client.this.id,
    COGNITO_JWKS_JSON           = data.http.cognito_jwks.response_body
  })

  depends_on = [
    data.http.cognito_jwks
  ]
}
