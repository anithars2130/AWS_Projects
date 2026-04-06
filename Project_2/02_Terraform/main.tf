# -------------------------------------------
# AWS Provider
# -------------------------------------------
provider "aws" {
  region = "us-east-1"
}

# -------------------------------------------
# S3 Bucket for Static Website
# -------------------------------------------
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name

  # Block all public ACLs (we'll use CloudFront OAI)
  acl = "private"

  # Recommended for new buckets
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.static_site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable static website hosting (required even with private bucket)
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# -------------------------------------------
# CloudFront Origin Access Identity
# -------------------------------------------
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.bucket_name}"
}

# -------------------------------------------
# Bucket Policy for CloudFront Access
# -------------------------------------------
resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontRead"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.static_site.bucket}/*"
      }
    ]
  })
}

# -------------------------------------------
# CloudFront Distribution
# -------------------------------------------
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Project = "Project_2_Static_Website"
    Owner   = "ANI"
    Environment = "dev"
  }
}