resource "aws_s3_bucket" "activestorage" {
  bucket = var.activestorage.s3_bucket

  tags = {
    application = "partiesforall"
  }
}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.activestorage.id
  block_public_acls = true
  block_public_policy = true
}

resource "aws_s3_bucket_cors_configuration" "application_cors" {
  bucket = aws_s3_bucket.activestorage.id

  cors_rule {
      allowed_headers = [
        "Content-Type",
        "Content-MD5",
        "Content-Disposition"
      ]
      allowed_methods = ["GET", "PUT", "POST", "HEAD"]
      allowed_origins = [
        for alias in local.aliases_with_main :
        "https://${alias}"
      ]
      max_age_seconds = 3000
  }
}

# a bit pricier than just archiving, but lets it control for access in the event of people reviewing old events
resource "aws_s3_bucket_lifecycle_configuration" "intelligent_tiering" {
  bucket = aws_s3_bucket.activestorage.id

  rule {
    id = "intelligent-everything"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    transition {
      storage_class = "INTELLIGENT_TIERING"
      days = 0
    }
  }
}