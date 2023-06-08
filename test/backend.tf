terraform {
  backend "s3" {
    bucket = "pumpbot-terraform-states"
    key    = "state_test"
    region = "ap-northeast-1"
    dynamodb_table = "terraform-lock"
    encrypt = true
  }
}
