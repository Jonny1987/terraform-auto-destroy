resource "terraform_data" "make_lambda_payload" {
  # Creates a zip of the root and proxies directory without any .terraform files
  provisioner "local-exec" {
    command     = "sh test.sh"
  }
}
