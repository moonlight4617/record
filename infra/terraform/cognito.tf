resource "aws_cognito_user_pool" "main" {
  name = "user_pool"

  auto_verified_attributes = [
    "email",
  ]
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    require_uppercase                = true
    temporary_password_validity_days = 7
  }
  user_attribute_update_settings {
    attributes_require_verification_before_update = [
      "email",
    ]
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "user_pool_client"
  user_pool_id = aws_cognito_user_pool.main.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  generate_secret = false
}

resource "aws_cognito_identity_provider" "google_provider" {
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Google"
  provider_type = "Google"
  provider_details = {
    "attributes_url"                = "https://people.googleapis.com/v1/people/me?personFields="
    "attributes_url_add_attributes" = "true"
    "authorize_scopes"              = "email profile openid"
    "authorize_url"                 = "https://accounts.google.com/o/oauth2/v2/auth"
    "client_id"                     = "" # secret情報なのでソースとして記載しない
    "client_secret"                 = "" # secret情報なのでソースとして記載しない
    "oidc_issuer"                   = "https://accounts.google.com"
    "token_request_method"          = "POST"
    "token_url"                     = "https://www.googleapis.com/oauth2/v4/token"
  }
  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "record-01"
  user_pool_id = aws_cognito_user_pool.main.id
}
