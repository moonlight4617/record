resource "aws_api_gateway_rest_api" "record_apigateway" {
  api_key_source = "HEADER"
  # TODO: 後ほど設定
  name = "test20241217"
  # description                  = "自作アプリrecord用のapigateway"
  disable_execute_api_endpoint = false
  minimum_compression_size     = -1
  put_rest_api_mode            = "overwrite"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = {}
}

resource "aws_api_gateway_resource" "child_resource" {
  parent_id   = aws_api_gateway_rest_api.record_apigateway.root_resource_id
  path_part   = "{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.record_apigateway.id
}

resource "aws_api_gateway_method" "root_any" {
  api_key_required = false
  authorization    = "NONE"
  http_method      = "ANY"
  resource_id      = aws_api_gateway_rest_api.record_apigateway.root_resource_id
  rest_api_id      = aws_api_gateway_rest_api.record_apigateway.id
}

resource "aws_api_gateway_method" "child_any" {
  api_key_required = false
  authorization    = "NONE"
  http_method      = "ANY"
  request_parameters = {
    "method.request.path.proxy" = true
  }
  request_validator_id = null
  resource_id          = aws_api_gateway_resource.child_resource.id
  rest_api_id          = aws_api_gateway_rest_api.record_apigateway.id
}

resource "aws_api_gateway_integration" "lambda_integration" {
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = aws_api_gateway_method.root_any.http_method
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  resource_id             = aws_api_gateway_rest_api.record_apigateway.root_resource_id
  rest_api_id             = aws_api_gateway_rest_api.record_apigateway.id
  timeout_milliseconds    = 29000
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_api_gateway_integration" "child_lambda_integration" {
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = aws_api_gateway_method.child_any.http_method
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  resource_id             = aws_api_gateway_resource.child_resource.id
  rest_api_id             = aws_api_gateway_rest_api.record_apigateway.id
  timeout_milliseconds    = 29000
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_api_gateway_method_response" "root_response_200" {
  rest_api_id = aws_api_gateway_rest_api.record_apigateway.id
  resource_id = aws_api_gateway_rest_api.record_apigateway.root_resource_id
  http_method = aws_api_gateway_method.root_any.http_method
  response_models = {
    "application/json" = "Empty"
  }
  status_code = "200"
}

resource "aws_api_gateway_method_response" "child_response_200" {
  rest_api_id = aws_api_gateway_rest_api.record_apigateway.id
  resource_id = aws_api_gateway_resource.child_resource.id
  http_method = aws_api_gateway_method.child_any.http_method
  response_parameters = {
    "method.response.header.Access-Control-Allow-Credentials" = false
    "method.response.header.Access-Control-Allow-Headers"     = false
    "method.response.header.Access-Control-Allow-Methods"     = false
    "method.response.header.Access-Control-Allow-Origin"      = false
  }
  status_code = "200"
}
