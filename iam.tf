resource "aws_iam_role" "worker_lambda_exec" {
  name = "worker_lambda_exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_full_access_policy" {
  name        = "lambda-full-access-policy"
  description = "Minimal required permissions for Lambda to function"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # CloudWatch Logs for logging
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],

       Resource = "arn:aws:logs:*:*:*"

      },
      # DynamoDB read, update, put
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
	  "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        Resource = aws_dynamodb_table.billing_metadata.arn
      },
      # S3 access for archiving old data
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.archive_bucket.arn,
          "${aws_s3_bucket.archive_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_full_policy_attach" {
  role       = aws_iam_role.worker_lambda_exec.name
  policy_arn = aws_iam_policy.lambda_full_access_policy.arn
}

