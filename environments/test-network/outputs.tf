output "vpc_main_id" {
  value = "${module.vpc.vpc_main_id}"
}

output "vpc_public_subnet_ids" {
  value = "${module.vpc.vpc_public_subnet_ids}"
}

output "vpc_private_subnet_ids" {
  value = "${module.vpc.vpc_private_subnet_ids}"
}

output "sg_egress_id" {
  value = "${module.sg_egress.id}"
}

