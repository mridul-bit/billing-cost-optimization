output "lambda_function_name" {
  description = "Name of the archival Lambda function"
  value       = aws_lambda_function.worker_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the archival Lambda function"
  value       = aws_lambda_function.worker_lambda.arn
}

output "s3_archive_bucket_name" {
  description = "Name of the S3 bucket used for cold billing data"
  value       = aws_s3_bucket.archive_bucket.bucket
}

output "s3_archive_bucket_arn" {
  description = "ARN of the S3 archive bucket"
  value       = aws_s3_bucket.archive_bucket.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table storing metadata"
  value       = aws_dynamodb_table.billing_metadata.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.billing_metadata.arn
}

output "eventbridge_rule_name" {
  description = "Name of the EventBridge rule that triggers the Lambda"
  value       = aws_cloudwatch_event_rule.daily_lambda_trigger.name
}

