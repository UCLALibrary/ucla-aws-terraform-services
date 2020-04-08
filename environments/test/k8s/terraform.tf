terraform {
  required_version = "~> 0.12.20"
  backend "remote" {}
#  backend "s3" {
#    encrypt = true
#    bucket = "prod-services-terraform-state"
#    region = "us-west-2"
#    key = "test/iiif-deployment"
#    dynamodb_table = "terraform-state-lock-dynamo"
#  }
}
