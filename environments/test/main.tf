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
  source                        = "../../modules/cantaloupe"
  vpc_main_id                   = "${module.vpc.vpc_main_id}"
  vpc_subnet_ids                = "${module.vpc.vpc_subnet_ids}"
  alb_main_id                   = "${module.alb.alb_main_id}"
  alb_main_sg_id                = "${module.alb.alb_main_sg_id}"
  app_port                      = "${var.iiif_app_port}"
  registry_url                  = "${var.registry_url}"
  app_name                      = "${var.iiif_app_name}"
  cantaloupe_cpu                = "${var.cantaloupe_cpu}"
  cantaloupe_memory             = "${var.cantaloupe_memory}"
  dockerauth_arn                = "${var.dockerauth_arn}"
  dockerhubauth_credentials_arn = "${var.dockerhubauth_credentials_arn}"
  cantaloupe_processor_selection_strategy = "${var.cantaloupe_processor_selection_strategy}"
  cantaloupe_manual_processor_jp2         = "${var.cantaloupe_manual_processor_jp2}"
  cantaloupe_enable_admin                 = "${var.cantaloupe_enable_admin}"
  cantaloupe_admin_secret                 = "${var.cantaloupe_admin_secret}"
  s3_source_basiclookup_suffix            = "${var.s3_source_basiclookup_suffix}"
  cantaloupe_heapsize                     = "${var.cantaloupe_heapsize}"
  cantaloupe_enable_cache_server          = "${var.cantaloupe_enable_cache_server}"
  cantaloupe_cache_server_derivative      = "${var.cantaloupe_cache_server_derivative}"
  cantaloupe_cache_server_derivative_ttl  = "${var.cantaloupe_cache_server_derivative_ttl}"
  cantaloupe_cache_server_purge_missing   = "${var.cantaloupe_cache_server_purge_missing}"
  s3_cache_access_key                     = "${var.s3_cache_access_key}"
  s3_cache_secret_key                     = "${var.s3_cache_secret_key}"
  s3_cache_bucket                         = "${var.s3_cache_bucket}"
  s3_cache_endpoint                       = "${var.s3_cache_endpoint}"
  cantaloupe_source_static      = "${var.cantaloupe_source_static}"
  s3_source_access_key          = "${var.s3_source_access_key}"
  s3_source_secret_key          = "${var.s3_source_secret_key}"
  s3_source_bucket              = "${var.s3_source_bucket}"
  s3_source_endpoint            = "${var.s3_source_endpoint}"
}
