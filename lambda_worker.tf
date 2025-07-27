resource "aws_lambda_function" "worker_lambda" {
  function_name = "billing-worker-lambda"
  role          = aws_iam_role.worker_lambda_exec.arn
  handler       = "main.handler"
  runtime       = "python3.12"
  timeout       = 900

  filename         = "lambda.zip"
 

  environment {
    variables = {
     
      COSMOSDB_ENDPOINT    = var.cosmosdb_endpoint
      COSMOSDB_KEY         = var.cosmosdb_key
      COSMOSDB_DB          = var.cosmosdb_db
      COSMOSDB_CONTAINER   = var.cosmosdb_container

      DYNAMO_TABLE         = var.dynamodb_table_name
      S3_BUCKET            = var.archive_bucket_name
  
    }
  }
}

