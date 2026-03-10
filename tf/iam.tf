# =============================================================================
# IAM Roles and Policies for Lambda Functions
# =============================================================================

# -----------------------------------------------------------------------------
# Data sources
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# Lambda Execution Role
# -----------------------------------------------------------------------------

# Trust policy for Lambda service
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM Role for Lambda functions
resource "aws_iam_role" "lambda_execution" {
  name               = "${local.name_prefix}-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# CloudWatch Logs Policy
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_cloudwatch_logs" {
  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name_prefix}*:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_cloudwatch_logs" {
  name        = "${local.name_prefix}-lambda-cloudwatch-logs"
  description = "Allow Lambda functions to write to CloudWatch Logs"
  policy      = data.aws_iam_policy_document.lambda_cloudwatch_logs.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_logs" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs.arn
}

# -----------------------------------------------------------------------------
# DynamoDB Policy (Principle of Least Privilege)
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_dynamodb" {
  statement {
    sid    = "AllowDynamoDBCrud"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      aws_dynamodb_table.this.arn,
      "${aws_dynamodb_table.this.arn}/index/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_dynamodb" {
  name        = "${local.name_prefix}-lambda-dynamodb"
  description = "Allow Lambda functions to access DynamoDB table"
  policy      = data.aws_iam_policy_document.lambda_dynamodb.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}
