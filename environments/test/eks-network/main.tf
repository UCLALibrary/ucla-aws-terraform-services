terraform {
  backend "remote" {}
}

provider "aws" {
  shared_credentials_file   = var.cred_file
  profile                   = var.cred_profile
  region                    = var.region
}

##### Public subnets ######
##### 172.50.10.0/24 AZ 1
##### 172.50.11.0/24 AZ 2
##### 172.50.12.0/24 AZ 3
##### Private subnets ######
##### 172.50.100.0/24 AZ 1
##### 172.50.100.0/24 AZ 2
##### 172.50.100.0/24 AZ 3
##### NAT Gateway to be created, but not forcing all egress traffic to use the NAT gateway
module "eks_vpc" {
  source                    = "git::https://github.com/UCLALibrary/aws_terraform_module_vpc.git"
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_count       = var.public_subnet_count
  public_subnet_init_value  = var.public_subnet_int
  private_subnet_count      = var.private_subnet_count
  private_subnet_init_value = var.private_subnet_int
  enable_nat                = var.enable_nat
  vpc_tag_map               = var.vpc_tag_map
  subnet_tag_map            = var.k8s_subnet_tag_map
  default_tag_map           = var.default_tag_map
}

### Create route table to allow private networks to use IGW for egress, but use NAT gateway when accessing campus and/or specified IPs
resource "aws_route_table" "nat_egress_known" {
  vpc_id = module.eks_vpc.vpc_main_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.eks_vpc.public_igw_id
  }

  route {
    cidr_block = "164.67.40.0/24"
    gateway_id = module.eks_vpc.private_nat_gateway_id
  }

  tags = var.default_tag_map
}

### Associate created route table to private subnets
resource "aws_route_table_association" "associate_nat_egress_known" {
  for_each = toset(module.eks_vpc.vpc_private_subnet_ids)
  subnet_id = each.key
  route_table_id = aws_route_table.nat_egress_known.id
}

module "default_sg_egress" {
  source                    = "git::https://github.com/UCLALibrary/aws_terraform_module_security_group.git"
  sg_name                   = "test-eks-environment-egress_allowed"
  sg_description            = "Allow test eks environment to make global egress calls"
  vpc_id                    = module.eks_vpc.vpc_main_id
  ingress_ports             = []
  ingress_allowed           = null
  sg_groups                 = null
  default_tag               = var.default_tag
}

module "allow_ssh_ingress" {
  source                    = "git::https://github.com/UCLALibrary/aws_terraform_module_security_group.git"
  sg_name                   = "test-eks-environment-jump_ingress_allowed"
  sg_description            = "Allow jump and ansible server to access resource on port 22"
  vpc_id                    = module.eks_vpc.vpc_main_id
  ingress_ports             = [22]
  ingress_allowed           = ["164.67.40.211/32", "164.67.40.235/32"]
  sg_groups                 = null
  default_tag               = var.default_tag
}

module "allow_http_https_ingress" {
  source                    = "git::https://github.com/UCLALibrary/aws_terraform_module_security_group.git"
  sg_name                   = "test-eks-environment-web_ingress_allowed"
  sg_description            = "Allow 80/443 ingress traffic to resources"
  vpc_id                    = module.eks_vpc.vpc_main_id
  ingress_ports             = [80,443]
  ingress_allowed           = ["0.0.0.0/0"]
  sg_groups                 = null
  default_tag               = var.default_tag
}

