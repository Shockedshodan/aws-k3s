variable "bucket_name" {
  description = "The name of the S3 bucket to store Terraform state"
  type        = string
}

variable "versioning_status" {
  description = "The versioning status of the S3 bucket"
  type        = string
  default     = "Enabled"
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use"
  type        = string
  default     = "AES256"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}
