terraform {
  required_version = "~> 0.12.20"
  backend "s3" {
    encrypt = true
    bucket = "prod-services-terraform-state"
    region = "us-west-2"
    key = "prod/vpc-state"
    dynamodb_table = "prod-services-terraform-state-lock"
  }
}
