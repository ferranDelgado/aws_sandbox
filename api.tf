/*
* Upload jar to s3
*/
resource "aws_s3_bucket_object" "jar" {
  depends_on = [aws_s3_bucket.frontend]
  bucket = aws_s3_bucket.frontend.bucket
  key = "jars/api.jar"
  source = "${path.module}/build/libs/api.jar"
  etag = filemd5("${path.module}/build/libs/api.jar")
}



// Lambda
resource "aws_lambda_function" "list_lambda" {
  depends_on        = [aws_s3_bucket_object.jar]
  runtime           = "java8"
  s3_bucket         = aws_s3_bucket_object.jar.bucket
  s3_key            = aws_s3_bucket_object.jar.key
  source_code_hash  = filesha256(aws_s3_bucket_object.jar.source)
  function_name     = "aws_sandbox_list"

  handler           = "cat.aws.sandbox.App::list"
  timeout           = 600
  memory_size       = 1024
  role              = aws_iam_role.iam_role_for_lambda.arn
}

// Lambda
resource "aws_lambda_function" "add_lambda" {
  depends_on        = [aws_s3_bucket_object.jar]
  runtime           = "java8"
  s3_bucket         = aws_s3_bucket_object.jar.bucket
  s3_key            = aws_s3_bucket_object.jar.key
  source_code_hash  = filesha256(aws_s3_bucket_object.jar.source)
  function_name     = "aws_sandbox_add"

  handler           = "cat.aws.sandbox.App::add"
  timeout           = 600
  memory_size       = 1024
  role              = aws_iam_role.iam_role_for_lambda.arn
}

resource "aws_lambda_permission" "java_add_lambda_function" {
  depends_on = [aws_lambda_function.add_lambda]
  // for_each = toset([aws_lambda_function.add_lambda.arn, aws_lambda_function.list_lambda.arn])
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.aws_sandbox.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "java_list_lambda_function" {
  depends_on = [aws_lambda_function.list_lambda]
  // for_each = toset([aws_lambda_function.add_lambda.arn, aws_lambda_function.list_lambda.arn])
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.aws_sandbox.execution_arn}/*/*/*"
}

// Api
resource "aws_api_gateway_rest_api" "aws_sandbox" {
  name        = "aws_sandbox"
  description = "Main Api"
}


resource "aws_api_gateway_deployment" "root" {
  depends_on  = [aws_api_gateway_integration.root_api_get, aws_api_gateway_integration.root_api_post]
  rest_api_id = aws_api_gateway_rest_api.aws_sandbox.id
  stage_name  = "my-walk-root-stage-name"
  variables = {
    deployed_at = timestamp()
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "root_api" {
  depends_on = [aws_api_gateway_rest_api.aws_sandbox]
  rest_api_id = aws_api_gateway_rest_api.aws_sandbox.id
  parent_id = aws_api_gateway_rest_api.aws_sandbox.root_resource_id
  path_part = "api"
}

/**
 * GET
 */
resource "aws_api_gateway_method" "root_api_get" {
  depends_on = [aws_api_gateway_resource.root_api]
  rest_api_id = aws_api_gateway_rest_api.aws_sandbox.id
  resource_id = aws_api_gateway_resource.root_api.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_api_get" {
  depends_on              = [aws_api_gateway_method.root_api_get]
  rest_api_id             = aws_api_gateway_rest_api.aws_sandbox.id
  resource_id             = aws_api_gateway_resource.root_api.id
  http_method             = aws_api_gateway_method.root_api_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = aws_lambda_function.list_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "get_response_200" {
  depends_on = [aws_api_gateway_method.root_api_get]
  rest_api_id = aws_api_gateway_rest_api.aws_sandbox.id
  resource_id = aws_api_gateway_resource.root_api.id
  http_method = aws_api_gateway_method.root_api_get.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "get_response_200" {
  depends_on = [aws_api_gateway_integration.root_api_get]
  rest_api_id = aws_api_gateway_rest_api.aws_sandbox.id
  resource_id = aws_api_gateway_integration.root_api_get.resource_id
  http_method = aws_api_gateway_integration.root_api_get.http_method
  status_code = "200"
  response_templates = {
    "application/json" = "Empty"
  }
}
// ------------------------------------------------------------------

/**
 * POST
 */
resource "aws_api_gateway_method" "root_api_post" {
  depends_on = [aws_api_gateway_resource.root_api]
  rest_api_id = aws_api_gateway_rest_api.aws_sandbox.id
  resource_id = aws_api_gateway_resource.root_api.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_api_post" {
  depends_on              = [aws_api_gateway_method.root_api_post]
  rest_api_id             = aws_api_gateway_rest_api.aws_sandbox.id
  resource_id             = aws_api_gateway_resource.root_api.id
  http_method             = aws_api_gateway_method.root_api_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = aws_lambda_function.add_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "post_response_200" {
  depends_on = [aws_api_gateway_method.root_api_post]
  rest_api_id = aws_api_gateway_rest_api.aws_sandbox.id
  resource_id = aws_api_gateway_resource.root_api.id
  http_method = aws_api_gateway_method.root_api_post.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "post_response_200" {
  depends_on = [aws_api_gateway_integration.root_api_post]
  rest_api_id = aws_api_gateway_rest_api.aws_sandbox.id
  resource_id = aws_api_gateway_integration.root_api_post.resource_id
  http_method = aws_api_gateway_method.root_api_post.http_method
  status_code = "200"
  response_templates = {
    "application/json" = "Empty"
  }
}
// ------------------------------------------------------------------

module "example_cors" {
  depends_on = [aws_api_gateway_resource.root_api, aws_api_gateway_method.root_api_get, aws_api_gateway_method.root_api_post]
  source  = "mewa/apigateway-cors/aws"
  version = "2.0.0"

  api = aws_api_gateway_rest_api.aws_sandbox.id
  resource = aws_api_gateway_resource.root_api.id

  methods = ["GET", "POST", "OPTION"]
}


output "api_url" {
  value = aws_api_gateway_deployment.root.invoke_url
}