
variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Name prefix for resources"
  default     = "cold-archival"
}

variable "archive_bucket_name" {
  type        = string
  description = "S3 bucket name for archived billing data"
  default     = "cold-billing-archive-data"
}


variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table for cold data metadata index"
  default     = "billing-records-metadata"
}

variable "cosmosdb_endpoint" {
  description = "Azure CosmosDB endpoint"
  type        = string
}

variable "cosmosdb_key" {
  description = "Azure CosmosDB key"
  type        = string
  sensitive   = true
}

variable "cosmosdb_db" {
  description = "Cosmos DB database name"
  type        = string
}

variable "cosmosdb_container" {
  description = "Cosmos DB container name"
  type        = string
}

