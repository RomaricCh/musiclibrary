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
  lambda_find_function_name   = "${local.name_prefix}-find-song"
  lambda_create_function_name = "${local.name_prefix}-create-song"
  lambda_delete_function_name = "${local.name_prefix}-delete-song"

  # Hash des fichiers sources des Lambdas (src/ + dépendances) pour détecter
  # les changements de code.
  lambda_source_hash = sha256(join("", concat(
    [for f in sort(fileset("${path.module}/../src", "**/*.py")) : filesha256("${path.module}/../src/${f}")],
    [filesha256("${path.module}/../pyproject.toml")],
    [filesha256("${path.module}/../uv.lock")]
  )))
}
