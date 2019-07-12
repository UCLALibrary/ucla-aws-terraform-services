terraform {
  backend "s3" {
    bucket = "softwaredev-services-terraform"
    key    = "test-cantaloupe/terraform.tfstate"
    region = "us-west-2"
    profile = "services"
  }
}

provider "aws" {
  shared_credentials_file = "${var.cred_file}"
  profile                 = "${var.cred_profile}"
  region                  = "${var.region}"
}

module "vpc" {
  source            = "../../modules/vpc"
  custom_cidr_block = "172.17.0.0/16"
  subnet_count      = 3
}

#module "cantaloupe" {
#  source = "../../modules/cantaloupe"
#  app_port = 8182
#  registry_url = "registry.hub.docker.com/uclalibrary/cantaloupe-ucla:4.1.1"
#  app_cidr_block = "172.17.0.0/16"
#  app_name = "iiif.library.ucla.edu"
#}
