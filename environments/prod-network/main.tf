terraform {
  backend "remote" {}
}

provider "aws" {
  shared_credentials_file = "${var.cred_file}"
  profile                 = "${var.cred_profile}"
  region                  = "${var.region}"
}

module "vpc" {
  source                    = "git::https://github.com/UCLALibrary/aws_terraform_module_vpc.git"
  vpc_cidr_block            = "${var.vpc_cidr_block}"
  public_subnet_count       = "${var.public_subnet_count}"
  public_subnet_init_value  = "${var.public_subnet_int}"
  private_subnet_count      = "${var.private_subnet_count}"
  private_subnet_init_value = "${var.private_subnet_int}"
  vpc_endpoint              = "${var.vpc_endpoint}"
  create_vpc_endpoint       = "${var.create_vpc_endpoint}"
  enable_nat                = "${var.enable_nat}"
}

module "sg_egress" {
  source           = "git::https://github.com/UCLALibrary/aws_terraform_module_security_group.git"
  sg_name          = "iiif-egress_allowed"
  sg_description   = "iiif-global-egress-rule"
  vpc_id           = "${module.vpc.vpc_main_id}"
  ingress_ports    = []
  ingress_allowed  = null
  sg_groups        = null
}

