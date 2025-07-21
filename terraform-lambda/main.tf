provider "aws" {
  region  = var.region
  profile = "lambda-deployer"
}

# === IAM Role for Lambda Execution ===
resource "aws_iam_role" "lambda_exec_role" {
  name               = "${var.lambda_name}-exec-role-v3"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# === Lambda Function Definition ===
resource "aws_lambda_function" "go_lambda" {
  function_name = var.lambda_name
  filename      = "${path.module}/../main.zip"
  handler       = "bootstrap"
  runtime       = "provided.al2"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 10

  source_code_hash = filebase64sha256("${path.module}/../main.zip")
}

# === API Gateway REST API ===
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.lambda_name}-api"
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "allow_api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.go_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The API Gateway ID is required to allow the API Gateway to invoke the Lambda function
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.go_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /api/greet"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}