module "lambda_destroy" {
  source = "git::https://github.com/Jonny1987/terraform-auto-destroy.git//lambda"
  lambda_function_name = "terraform_destroy_lambda"
}
