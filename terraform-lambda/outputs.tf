output "lambda_function_name" {
  value = aws_lambda_function.go_lambda.function_name
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}