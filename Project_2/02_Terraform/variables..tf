variable "bucket_name" {
  description = "Name of the S3 bucket for static website"
  type        = string
  default     = "ani-static-website-197"

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters."
  }
}