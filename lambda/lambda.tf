resource "terraform_data" "make_lambda_payload" {
  # Creates a zip of the root and proxies directory without any .terraform files
  provisioner "local-exec" {
    command     = "zip -x \"../${var.main_directory_name}/.*\" -x \"../${var.main_directory_name}/.*/.*\" -r lambda_function_payload.zip ../${var.main_directory_name}/ && zip -jr lambda_function_payload.zip terraform_destroy_lambda.py"
  }
}

data "aws_lambda_layer_version" "terraform_git" {
  layer_name = "terraform-git-layer"
}

resource "aws_lambda_function" "terraform_destroy_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "terraform_destroy_lambda.run"
  runtime       = "python3.9"
  timeout       = "300"
  memory_size   = "1024"

  layers = [data.aws_lambda_layer_version.terraform_git.arn]

  environment {
    variables = {
      LD_LIBRARY_PATH = "/opt/lib"
    }
  }

  provisioner "local-exec" {
    command = "rm lambda_function_payload.zip"
  }
}
