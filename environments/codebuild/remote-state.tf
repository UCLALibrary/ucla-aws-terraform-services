### Retrieve IAM arns to use
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "prod-services-terraform-state"
    key = "prod/iam-state"
    region = "us-west-2"
  }
}
