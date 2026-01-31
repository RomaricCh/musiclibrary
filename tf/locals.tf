# =============================================================================
# Local Variables
# =============================================================================

locals {
  # Naming prefix for all resources
  name_prefix = "${var.project_name}-${var.stage}"

  # Common tags for all resources (in addition to provider default_tags)
  common_tags = {
    Application = var.project_name
  }

  # DynamoDB table name
  dynamodb_table_name = local.name_prefix

  # Lambda function names
  lambda_find_function_name   = "${local.name_prefix}-find-hello-msg"
  lambda_create_function_name = "${local.name_prefix}-create-hello-msg"

  # Lambda source path (relative to tf directory)
  lambda_source_path = "${path.module}/../src"
}
