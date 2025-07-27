resource "aws_cloudwatch_event_rule" "daily_lambda_trigger" {
  name                = "daily-worker-lambda-trigger"
  schedule_expression = "rate(1 day)"
  description         = "Triggers the lambda every day"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_lambda_trigger.name
  target_id = "WorkerLambdaTarget"
  arn       = aws_lambda_function.worker_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.worker_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_lambda_trigger.arn
}

