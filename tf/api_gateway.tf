# =============================================================================
# API Gateway REST API (OpenAPI Integration)
# =============================================================================

# -----------------------------------------------------------------------------
# REST API with OpenAPI Specification
# -----------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "main" {
  name        = "${local.name_prefix}-api"
  description = "REST API for ${var.stage}"

  # Import OpenAPI specification with variable substitution
  body = templatefile("${path.module}/../spec/api-spec-terraform.yaml", {
    aws_region             = var.aws_region
    find_song_lambda_arn   = aws_lambda_function.find_song.invoke_arn
    create_song_lambda_arn = aws_lambda_function.create_song.invoke_arn
    delete_song_lambda_arn = aws_lambda_function.delete_song.invoke_arn
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  # Permet la mise à jour du body si le fichier OpenAPI change
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api"
  })
}

# -----------------------------------------------------------------------------
# Lambda Permissions for API Gateway
# -----------------------------------------------------------------------------

resource "aws_lambda_permission" "api_gateway_create" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_song.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_find" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.find_song.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_delete" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_song.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}


# -----------------------------------------------------------------------------
# API Gateway Deployment
# -----------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    # Redeploy when the OpenAPI spec or Lambda ARNs change
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.main.body
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# API Gateway Stage
# -----------------------------------------------------------------------------

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.api_stage_name

  # Enable CloudWatch logging
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId         = "$context.requestId"
      sourceIp          = "$context.identity.sourceIp"
      requestTime       = "$context.requestTime"
      protocol          = "$context.protocol"
      httpMethod        = "$context.httpMethod"
      resourcePath      = "$context.resourcePath"
      routeKey          = "$context.routeKey"
      status            = "$context.status"
      responseLength    = "$context.responseLength"
      integrationError  = "$context.integrationErrorMessage"
      integrationStatus = "$context.integrationStatus"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-${var.api_stage_name}"
  })
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group for API Gateway
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api-gateway/${local.name_prefix}-api"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-logs"
  })
}

# -----------------------------------------------------------------------------
# API Gateway Method Settings (throttling, etc.)
# -----------------------------------------------------------------------------

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
  }
}
