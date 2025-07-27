# create s3 archive_bucket to store 90 days older data from cosmoDB

resource "aws_s3_bucket" "archive_bucket" {
  bucket = var.archive_bucket_name
  force_destroy = true

  tags = {
    Name        = var.archive_bucket_name
    Environment = "prod"
    Project     = var.project_name
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "archive_bucket_block" {
  bucket = aws_s3_bucket.archive_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "archive_bucket_sse" {
  bucket = aws_s3_bucket.archive_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "archive_bucket_versioning" {
  bucket = aws_s3_bucket.archive_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Intelligent-Tiering Lifecycle Rule
resource "aws_s3_bucket_lifecycle_configuration" "intelligent_tiering" {
  bucket = aws_s3_bucket.archive_bucket.id

  rule {
    id     = "enable-intelligent-tiering"
    status = "Enabled"


    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }


  }
}

