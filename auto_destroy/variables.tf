variable "lb_max_idle_time_minutes" {
  type        = number
  description = "Number of minutes of idle time of the load balancer after which the alarm will turn on and the terraform destroy lambda function called"
}

variable "lambda_function_name" {
  type        = string
  default     = "terraform_destroy"
  description = "The name of the terraform destroy lambda function"
}

variable "instance_id" {
  type        = string
  description = "The ID of the instance being monitored"
}
