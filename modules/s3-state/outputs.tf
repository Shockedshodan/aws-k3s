output "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = try(aws_s3_bucket.this.id, "")
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.this.name
}