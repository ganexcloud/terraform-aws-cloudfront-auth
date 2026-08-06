output "bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.this.id
}

output "bucket_domain_name" {
  description = "S3 Bucket Domain Name"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_arn" {
  description = "The ARN of the S3 Bucket project."
  value       = aws_s3_bucket.this.arn
}

output "cloudfront_id" {
  description = "The identifier for the cloudfront distribution"
  value       = aws_cloudfront_distribution.this.id
}

output "cloudfront_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution."
  value       = aws_cloudfront_distribution.this.arn
}
