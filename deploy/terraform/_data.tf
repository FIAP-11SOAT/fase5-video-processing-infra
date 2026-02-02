data "http" "cognito_jwks" {
  url = "https://${aws_cognito_user_pool.this.endpoint}/.well-known/jwks.json"

  request_headers = {
    Accept = "application/json"
  }

  depends_on = [
    aws_cognito_user_pool.this
  ]
}

