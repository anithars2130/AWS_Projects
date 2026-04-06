output "bucket_website_endpoint" {
  description = "S3 static website endpoint"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "cloudfront_url" {
  description = "CloudFront distribution HTTP URL"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_https_url" {
  description = "CloudFront distribution HTTPS URL"
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}

output "cloudfront_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.cdn.arn
}