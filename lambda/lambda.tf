resource "terraform_data" "make_lambda_payload" {
  # Creates a zip of the root and proxies directory without any .terraform files
  provisioner "local-exec" {
    command     = "zip -x \"main/.*\" -x \"main/.*/.*\" -r lambda_function_payload.zip main/ && zip -jr lambda_function_payload.zip lambda/terraform_destroy_lambda.py"
    working_dir = "../"
  }
}

resource "aws_lambda_layer_version" "terraform_layer" {
  filename   = "terraform.zip"
  layer_name = "terraform_layer"
  skip_destroy = true
}

resource "aws_lambda_function" "terraform_destroy_lambda" {
  filename      = "../lambda_function_payload.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "terraform_destroy_lambda.run"
  runtime       = "python3.9"
  timeout       = "300"
  memory_size   = "1024"

  layers = [aws_lambda_layer_version.terraform_layer.arn]

  provisioner "local-exec" {
    command = "rm ../lambda_function_payload.zip"
  }
}
