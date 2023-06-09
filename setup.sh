set -e
curl -O https://raw.githubusercontent.com/Jonny1987/terraform-auto-destroy/master/lambda/terraform_destroy_lambda.py
curl -o lambda_payload.tf https://raw.githubusercontent.com/Jonny1987/terraform-auto-destroy/master/lambda/lambda_payload.txt
curl "https://releases.hashicorp.com/terraform/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')/terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')_linux_amd64.zip" -o terraform.zip

