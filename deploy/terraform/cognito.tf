resource "aws_cognito_user_pool" "this" {
  name = "${var.project_name}-user-pool"

  username_configuration {
    case_sensitive = false
  }

  mfa_configuration        = "OFF"
  auto_verified_attributes = []

  alias_attributes         = ["email", "preferred_username"]

  schema {
    attribute_data_type      = "String"
    name                     = "email"
    required                 = true
    mutable                  = true
    developer_only_attribute = false
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.project_name}-auth-client"
  user_pool_id = aws_cognito_user_pool.this.id

  explicit_auth_flows = [
    "USER_PASSWORD_AUTH",
    "ADMIN_NO_SRP_AUTH",
  ]
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.this.id
}
