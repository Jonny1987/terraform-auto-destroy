# terraform-destroy-lambda
Modules for creating aws infrastructure with terraform which automatically gets destroyed after a certain time by a lambda function.
It assumes that there is a load balancer running on an ec2 instance which has the resource name of "load_balancer".

There are two separate modules:
- lambda: this is the module for the lambda function which will run the 'terraform destroy'.
- auto-destroy: this is the modulie for the metric and alarm for monitoring the load balancer usage and triggering the lambda function


# Structure
Create the following terraform projects in the same directory for the auto_destroy to work:

main/
  The terraform project which contains your infrastructure with load balancer which is being monitored. This load balancer must have resource name of "load_balancer".
  This project also loads the "auto-destroy" terraform module located at

destroy_lambda/ - terraform project which just loads the lambda function to destroy the infrastructure located at 


# Variables of modules
auto_destroy:
  lb_max_idle_time_minutes - The number of minutes that the load balancer needs to be idle for before the lambda function is called


### To start

1) download the latest terraform binary for the lambda layer payload:
   `cd destroy_lambda; curl "https://releases.hashicorp.com/terraform/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')/terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')_linux_amd64.zip" -o terraform.zip`

2) create the lambda function:
   `cd destroy_lambda; terraform apply`

3) create the infrastructure:
   `cd ../main; terraform apply`
   
After the time duration given, the infrastructure will be destroyed by the lambda function
