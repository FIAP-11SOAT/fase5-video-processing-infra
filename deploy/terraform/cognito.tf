# resource "aws_cognito_user_pool" "this" {
#   name = "${var.project_name}-users"
#
#   mfa_configuration        = "OFF"
#   auto_verified_attributes = []
#
#   admin_create_user_config {
#     allow_admin_create_user_only = true
#   }
#
#   schema {
#     name                = "email"
#     attribute_data_type = "String"
#     required            = true
#     mutable             = true
#     string_attribute_constraints {
#       min_length = 1
#       max_length = 256
#     }
#   }
#
#   password_policy {
#     require_lowercase = true
#     minimum_length    = 8
#     require_numbers   = true
#     require_symbols   = true
#     require_uppercase = true
#   }
#
# }
#
# resource "aws_cognito_user_pool_client" "user_pool_client" {
#   name                = "${local.project_name}-pool-client"
#   user_pool_id        = aws_cognito_user_pool.user_pool.id
#   explicit_auth_flows = ["ALLOW_ADMIN_USER_PASSWORD_AUTH"]
# }