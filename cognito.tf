resource "aws_cognito_user_pool" "pool" {
  name = "aws_sandbox"
}

resource "aws_cognito_user_pool_client" "client" {
  name = "aws_sandbox_web_app"

  user_pool_id = aws_cognito_user_pool.pool.id
}