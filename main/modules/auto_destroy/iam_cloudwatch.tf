resource "aws_lambda_permission" "allow_sns_to_run_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.terraform_destroy_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.run_lambda_function.arn
}
