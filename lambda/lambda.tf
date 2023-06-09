resource "aws_lambda_layer_version" "terraform_layer" {
  filename   = "terraform.zip"
  layer_name = "terraform_layer_new"
  skip_destroy = true
}

resource "aws_lambda_function" "terraform_destroy_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "terraform_destroy_lambda.run"
  runtime       = "python3.9"
  timeout       = "300"
  memory_size   = "1024"

  layers = [aws_lambda_layer_version.terraform_layer.arn, "arn:aws:lambda:${var.region}:553035198032:layer:git:14"]

  provisioner "local-exec" {
    command = "rm lambda_function_payload.zip"
  }
}
