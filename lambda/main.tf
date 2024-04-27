terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.14"
}

provider "aws" {
  region = "us-east-1"
}

# AWS Role to be used by lambda function
# This role has 2 policyes attached to it
# trusted policy - defining who can assume this role
# identity policy - defining what action this lambda function can invoke
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "my_lambda" {
  function_name = "MyDotNetAppFunction"

  package_type = "Image"
  image_uri    = "230005740435.dkr.ecr.us-east-1.amazonaws.com/mydotnetapp:latest" # this is static URI for the image with tag "latest"

  role    = aws_iam_role.lambda_execution_role.arn
  timeout = 60
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "LambdaAPIGateway"
  description = "API Gateway for Lambda Function"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "mydotnetapp"
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"  # Deployment stage

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod-v2"
}

resource "aws_lambda_permission" "api_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Ensure the source ARN matches your API Gateway ARN
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

# Info for end users to connect to public API Gateway endpoints
output "lambda_function_arn" {
  value = aws_lambda_function.my_lambda.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.my_lambda.function_name
}

output "api_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/${aws_api_gateway_stage.api_stage.stage_name}/mydotnetapp"
}
