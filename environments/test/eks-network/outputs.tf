output "vpc_main_id" {
  value = "${module.eks_vpc.vpc_main_id}"
}

output "vpc_public_subnet_ids" {
  value = "${module.eks_vpc.vpc_public_subnet_ids}"
}

output "vpc_private_subnet_ids" {
  value = "${module.eks_vpc.vpc_private_subnet_ids}"
}

output "default_sg_egress_id" {
  value = "${module.default_sg_egress.id}"
}

output "allow_ssh_ingress_id" {
  value = "${module.allow_ssh_ingress.id}"
}

output "allow_http_https_ingress_id" {
  value = "${module.allow_http_https_ingress.id}"
}

