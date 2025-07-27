

resource "aws_dynamodb_table" "billing_metadata" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "billing_id"

  attribute {
    name = "billing_id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = var.dynamodb_table_name
    Environment = "prod"
    Project     = var.project_name
  }
}

