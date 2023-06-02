variable "lambda_function_name" {
  type        = string
  default     = "terraform_destroy"
  description = "The name of the lambda function in AWS"
}

variable "main_directory_name" {
  type        = string
  description = "The name of the directory in which is located the infrastructure that will be destroyed"
}
