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
  vpc_cidr_block    = "${var.vpc_cidr_block}"
  subnet_count      = "${var.subnet_count}"
  subnet_int        = "${var.subnet_int}"
}

module "alb" {
  source   = "../../modules/alb"
  app_name = "${var.iiif_app_name}"
  vpc_main_id = "${module.vpc.vpc_main_id}"
  vpc_subnet_ids = "${module.vpc.vpc_subnet_ids}"
}

module "cantaloupe" {
  source = "../../modules/cantaloupe"
  app_port = "${var.iiif_app_port}"
  registry_url = "registry.hub.docker.com/uclalibrary/cantaloupe-ucla:4.1.1"
  app_cidr_block = "172.17.0.0/16"
  app_name = "${var.iiif_app_name}"
}
