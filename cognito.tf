resource "aws_cognito_user_pool" "pool" {
  name = "aws_sandbox"

  # MFA & VERIFICATIONS
  mfa_configuration        = "OFF"
  auto_verified_attributes = ["email"]

  verification_message_template {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_message_by_link = "Your life will be dramatically improved by signing up! {##Click Here##}"
    email_subject_by_link = "Welcome to to a new world and life!"
  }
  email_configuration {
    reply_to_email_address = "a-email-for-people-to@reply.to"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "aws_sandbox_web_app"

  user_pool_id = aws_cognito_user_pool.pool.id
}