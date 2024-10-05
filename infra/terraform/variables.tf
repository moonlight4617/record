variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
  type        = string
  default     = "record-tfstate-01"
}

variable "lambda_bucket_name" {
  description = "The name of the lambda bucket. Must be globally unique."
  type        = string
  default     = "record-lambda-01"
}

variable "table_name" {
  description = "The name of the DynamoDB table. Must be unique in this AWS account."
  type        = string
  default     = "record-terraform-locks"
}
