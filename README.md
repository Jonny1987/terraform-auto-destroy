# terraform-destroy-lambda
Modules for creating aws infrastructure with terraform which automatically gets terraform destroyed after a amount of idle time by a lambda function.
It assumes that there is an ec2 instance which can be monitored for idleness.

There are two separate parts:
- lambda: this is a directory (not terraform module, for reasons explained in the FAQ) for the lambda function which will run the 'terraform destroy'.
- auto-destroy: this is the terraform module which sets up the infrastructure for monitoring the load balancer usage and triggering the lambda function


## Structure
Create the following terraform projects in the same directory for the auto_destroy to work:

main/
  The terraform project which contains your infrastructure with EC2 instance which is being monitored.
  This project needs to load the "auto-destroy" terraform module using the source path of `git::https://github.com/Jonny1987/terraform-auto-destroy.git//auto_destroy`.

lambda/ - terraform project which loads the lambda function for destroying the infrastructure. This needs directory needs to be copied (command show in setup instuctions below) instead of used as a modulule since it needs to be able to see the `main/` directory, and modules do not allow seeing parent or sibling directories.


## Arguments of modules/diretories
lambda:
  lambda_function_name - The name of the lambda function used for performing the terraform destroy. Defaults to "terraform_destroy"
  main_directory_name - The name of the directory in which is located the infrastructure which will be destroyed. Defaults to "main"

auto_destroy:
  lb_max_idle_time_minutes - The number of minutes that the load balancer needs to be idle for before the lambda function is called
  lambda_function_name - The name of the lambda function used in `lambda`. Defaults to "terraform_destroy"
  instance_id - The ID of the instance used for monitoring


## Setup

1) In the parent directory of `main/`, copy the `lambda/` directory from this repo:
  `curl https://github.com/Jonny1987/terraform-auto-destroy/archive/master.tar.gz -o /tmp/repo.tar.gz && tar -xf /tmp/repo.tar.gz --strip-components=1 terraform-auto-destroy-master/lambda/`

2) in `lambda/`, download the latest terraform binary for the lambda layer payload:
   `cd lambda; curl "https://releases.hashicorp.com/terraform/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')/terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')_linux_amd64.zip" -o terraform.zip`

3) create the lambda function (in `lambda/`):
   `terraform apply`

4) create the main infrastructure:
   `cd ../main; terraform apply`
   
After the time duration given, the infrastructure will be destroyed by the lambda function


## FAQ

1) I see git is used as a lambda layer. Where does this come from?

  This is from the following repository: `https://github.com/lambci/git-lambda-layer`

2) How do I make my own git lambda layer so I don't need to rely on someone elses?

  Use the yumda docker image (repository is https://github.com/lambci/yumda). This is a docker image which was created in order to make it easy to turn yum packages into lambda layers.

3) What is the `LD_PATH_LIBRARY` environment variable which is added to the lambda function?

  This tells lambda where to find the common library files needed for git to work. Lambda stores layers in `/opt`, and the library files are stored in `/opt/lib`

4) Is there a way to automatically retrieve the `lambda_function_name` from AWS after it has been created so I don't need to hard code it into `main/` when calling the `auto_destroy` module?

Yes, you can use a remote backend for the state in `lambda/`, and then use a `terraform_remote_state` data block in `main/` to retreive this state. Then you can get the `lambda_function_name` with `data.terraform_remote_state.<name>.outputs.lambda_function_name` (where `<name>` is the name you gave the `terraform_remote_state` block).
