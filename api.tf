/*
* Upload jar to s3
*/
resource "aws_s3_bucket_object" "jar" {
  bucket = var.bucket_name
  key = "jars/api.jar"
  source = "${path.module}/build/libs/api.jar"
  etag = filemd5("${path.module}/build/libs/api.jar")
}



// Lambda
resource "aws_lambda_function" "app_lambda" {
  depends_on        = [aws_s3_bucket_object.jar]
  runtime           = "java8"
  s3_bucket         = aws_s3_bucket_object.jar.bucket
  s3_key            = aws_s3_bucket_object.jar.key
  source_code_hash  = filesha256(aws_s3_bucket_object.jar.source)
  function_name     = "aws_sandbox_hello_world"

  handler           = "cat.aws.sandbox.App::handler"
  timeout           = 600
  memory_size       = 1024
  role              = aws_iam_role.iam_role_for_lambda.arn
}

resource "aws_lambda_permission" "java_lambda_function" {
  depends_on = [aws_api_gateway_rest_api.aws_sandbox]
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.aws_sandbox.id}/*/GET/"
}

// Api
resource "aws_api_gateway_rest_api" "aws_sandbox" {
  name        = "aws_sandbox"
  description = "Main Api"
}


resource "aws_api_gateway_deployment" "root" {
  depends_on  = [aws_api_gateway_integration.api_root]
  rest_api_id = aws_api_gateway_rest_api.aws_sandbox.id
  stage_name  = "my-walk-root-stage-name"
  variables = {
    deployed_at = timestamp()
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_integration" "api_root" {
  depends_on              = [aws_api_gateway_rest_api.aws_sandbox]
  rest_api_id             = aws_api_gateway_rest_api.aws_sandbox.id
  resource_id             = aws_api_gateway_rest_api.aws_sandbox.root_resource_id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = aws_lambda_function.app_lambda.invoke_arn
}

resource "aws_api_gateway_method" "my_walk_main_method" {
  depends_on = [aws_api_gateway_rest_api.aws_sandbox]
  rest_api_id   = aws_api_gateway_rest_api.aws_sandbox.id
  resource_id   = aws_api_gateway_rest_api.aws_sandbox.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}
