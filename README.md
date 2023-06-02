# terraform-destroy-lambda
Example of how to create aws infrastructure with terraform which automatically gets destroyed after a certain time by a lambda function.

There are two separate modules:
- lambda: this is the lambda function which will run the 'terraform destroy'.
- main: this is the main infrastructure that will be destroyed by the lambda function

### To start

1) create the lambda function:
   `cd lambda; terraform apply`

2) create the infrastructure:
   `cd ../main; terraform apply`
   
After the time duration given, the infrastructure will be destroyed by the lambda function
