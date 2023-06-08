resource "aws_cloudwatch_metric_alarm" "unused_lb" {
  alarm_name          = "unused_lb"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.lb_max_idle_time_minutes
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  statistic           = "Sum"
  period              = 60
  threshold           = 0
  treat_missing_data  = "missing"
  dimensions = {
    InstanceId = var.lb_id
  }

  alarm_actions = [aws_sns_topic.run_lambda_function.arn]
}

resource "aws_sns_topic" "run_lambda_function" {
  name = "run_terraform_destroy_lambda"
}

data "aws_lambda_function" "terraform_destroy_lambda" {
  function_name = var.lambda_function_name
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.run_lambda_function.arn
  protocol  = "lambda"
  endpoint  = data.aws_lambda_function.terraform_destroy_lambda.arn
}
