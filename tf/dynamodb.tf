# =============================================================================
# DynamoDB Table
# =============================================================================

resource "aws_dynamodb_table" "this" {
  name         = local.dynamodb_table_name
  billing_mode = var.dynamodb_billing_mode

  # Primary key
  hash_key = "uuid"

  # Attribute definitions
  attribute {
    name = "uuid"
    type = "S"
  }

  # Point-in-time recovery (recommandé pour prod)
  point_in_time_recovery {
    enabled = var.dynamodb_point_in_time_recovery
  }

  # Server-side encryption (enabled by default with AWS owned key)
  server_side_encryption {
    enabled = true
  }

  tags = local.common_tags
}
