# =============================================================================
# Lambda Functions
# =============================================================================

# -----------------------------------------------------------------------------
# Lambda Deployment Package
# -----------------------------------------------------------------------------

data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = local.lambda_source_path
  output_path = "${path.module}/.build/lambda_package.zip"
}

# -----------------------------------------------------------------------------
# CloudWatch Log Groups (créés explicitement pour contrôler la rétention)
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "find_hello_msg" {
  name              = "/aws/lambda/${local.lambda_find_function_name}"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Name = "${local.lambda_find_function_name}-logs"
  })
}

resource "aws_cloudwatch_log_group" "create_hello_msg" {
  name              = "/aws/lambda/${local.lambda_create_function_name}"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Name = "${local.lambda_create_function_name}-logs"
  })
}

# -----------------------------------------------------------------------------
# Lambda Function: Find Hello Message
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "find_hello_msg" {
  function_name = local.lambda_find_function_name
  description   = "Lambda function to find a hello message by UUID"

  role    = aws_iam_role.lambda_execution.arn
  handler = "handler.find_hello_msg"
  runtime = var.lambda_runtime

  filename         = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.helloworld.name
      ENVIRONMENT = var.stage
      LOG_LEVEL   = "INFO"
    }
  }

  tags = merge(local.common_tags, {
    Name = local.lambda_find_function_name
  })

  depends_on = [
    aws_cloudwatch_log_group.find_hello_msg,
    aws_iam_role_policy_attachment.lambda_cloudwatch_logs,
    aws_iam_role_policy_attachment.lambda_dynamodb
  ]
}

# -----------------------------------------------------------------------------
# Lambda Function: Create Hello Message
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "create_hello_msg" {
  function_name = local.lambda_create_function_name
  description   = "Lambda function to create a new hello message"

  role    = aws_iam_role.lambda_execution.arn
  handler = "handler.create_hello_msg"
  runtime = var.lambda_runtime

  filename         = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.helloworld.name
      ENVIRONMENT = var.stage
      LOG_LEVEL   = "INFO"
    }
  }

  tags = merge(local.common_tags, {
    Name = local.lambda_create_function_name
  })

  depends_on = [
    aws_cloudwatch_log_group.create_hello_msg,
    aws_iam_role_policy_attachment.lambda_cloudwatch_logs,
    aws_iam_role_policy_attachment.lambda_dynamodb
  ]
}
