# =============================================================================
# Lambda Functions
# =============================================================================

# -----------------------------------------------------------------------------
# Lambda Build (Exécution de la commande locale)
# -----------------------------------------------------------------------------

resource "null_resource" "build_lambda" {
  triggers = {
    hash_source = local.lambda_source_hash
  }

  provisioner "local-exec" {
    # On remonte d'un dossier pour se placer à la racine du projet
    working_dir = "${path.module}/.."
    command     = "inv build"
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Log Groups (créés explicitement pour contrôler la rétention)
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "find_hello_msg" {
  name              = "/aws/lambda/${local.lambda_find_function_name}"
  retention_in_days = 14

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "create_hello_msg" {
  name              = "/aws/lambda/${local.lambda_create_function_name}"
  retention_in_days = 14

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Lambda Function: Find Hello Message
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "find_hello_msg" {
  function_name = local.lambda_find_function_name
  description   = "Lambda function to find a hello message by UUID"

  role    = aws_iam_role.lambda_execution.arn
  handler = "src.handler.find_hello_msg"
  runtime = var.lambda_runtime

  # On pointe vers l'archive générée à la racine du projet
  filename         = "${path.module}/../lambda_function_payload.zip"
  source_code_hash = local.lambda_source_hash

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.this.name
      ENVIRONMENT = var.stage
      LOG_LEVEL   = "INFO"
    }
  }

  tags = local.common_tags

  depends_on = [
    null_resource.build_lambda # on attend que le build soit terminé
  ]
}

# -----------------------------------------------------------------------------
# Lambda Function: Create Hello Message
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "create_hello_msg" {
  function_name = local.lambda_create_function_name
  description   = "Lambda function to create a new hello message"

  role    = aws_iam_role.lambda_execution.arn
  handler = "src.handler.create_hello_msg"
  runtime = var.lambda_runtime

  # On pointe vers l'archive générée à la racine du projet
  filename         = "${path.module}/../lambda_function_payload.zip"
  source_code_hash = local.lambda_source_hash

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.this.name
      ENVIRONMENT = var.stage
      LOG_LEVEL   = "INFO"
    }
  }

  tags = local.common_tags

  depends_on = [
    null_resource.build_lambda # on attend que le build soit terminé
  ]
}
