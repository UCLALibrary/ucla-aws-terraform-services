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
  source            = "../../modules/cantaloupe"
  vpc_main_id       = "${module.vpc.vpc_main_id}"
  vpc_subnet_ids    = "${module.vpc.vpc_subnet_ids}"
  alb_main_id       = "${module.alb.alb_main_id}"
  alb_main_sg_id    = "${module.alb.alb_main_sg_id}"
  app_port          = "${var.iiif_app_port}"
  registry_url      = "registry.hub.docker.com/uclalibrary/cantaloupe-ucla:4.1.1"
  app_name          = "${var.iiif_app_name}"
  cantaloupe_cpu    = "${var.cantaloupe_cpu}"
  cantaloupe_memory = "${var.cantaloupe_memory}"
  dockerauth_arn    = "${var.dockerauth_arn}"
}
