resource "aws_api_gateway_rest_api" "example" {
  body = templatefile("./${var.open_api_file}", var.open_api_file_variables) 
  name = var.api_name
  endpoint_configuration {
    types = ["REGIONAL"]  
  }
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.example.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = var.stage_name
}

//allows the APIGW to invoke the lambda
resource "aws_lambda_permission" "lambda_permission" {
  for_each      = toset(var.function_names)
  statement_id  = "AllowRouteApiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/*"
}

resource "aws_api_gateway_usage_plan" "example" {
  name = var.api_name
  api_stages {
    api_id = aws_api_gateway_rest_api.example.id
    stage  = aws_api_gateway_stage.example.stage_name
  }
}

resource "aws_api_gateway_api_key" "example" {
  name        = var.api_name
  enabled     = true
  depends_on = [
    aws_api_gateway_usage_plan.example,
  ]
}

resource "aws_api_gateway_usage_plan_key" "example" {
  key_id        = aws_api_gateway_api_key.example.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.example.id
}
