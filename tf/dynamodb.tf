# =============================================================================
# DynamoDB Table
# =============================================================================

resource "aws_dynamodb_table" "this" {
  name         = local.dynamodb_table_name
  billing_mode = var.dynamodb_billing_mode

  # Primary key
  hash_key  = "author"
  range_key = "title"

  # Attribute definitions
  attribute {
    name = "author"
    type = "S"
  }

  attribute {
    name = "title"
    type = "S"
  }

  attribute {
    name = "date"
    type = "S"
  }

  attribute {
    name = "uuid"
    type = "S"
  }

  local_secondary_index {
    name            = "indexByAuthorAndDate"
    range_key       = "date"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "indexByUuid"
    hash_key        = "uuid"
    projection_type = "ALL"
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
