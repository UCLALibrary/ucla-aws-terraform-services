terraform {
  required_version = "~> 0.12.20"
  backend "remote" {}
}

provider "aws" {
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

module "allow_http_https_uclavpn" {
  source                    = "git::https://github.com/UCLALibrary/aws_terraform_module_security_group.git"
  sg_name                   = "terraform-test-iiif-allow-uclavpn"
  sg_description            = "Allow 80/443 ingress traffic to UCLA VPN Networks"
  vpc_id                    = module.eks_vpc.vpc_main_id
  ingress_ports             = [80,443]
  ingress_allowed           = [
                                "164.67.30.0/23",
                                "164.67.34.0/24",
                                "164.67.40.0/22",
                                "164.67.44.0/23",
                                "164.67.46.0/24",
                                "164.67.53.0/24",
                                "164.67.58.0/23",
                                "164.67.80.0/24",
                                "164.67.200.0/23",
                                "164.67.202.0/24",
                                "164.67.218.0/23",
                                "164.67.220.0/23",
                                "128.97.224.0/24",
                                "128.97.228.0/24",
                                "128.97.232.0/24",
                                "128.97.234.0/24",
                                "128.97.244.0/23",
                                "164.67.88.0/23",
                                "164.67.90.0/23",
                                "164.67.112.0/23",
                                "164.67.114.0/23",
                                "164.67.116.0/23",
                                "164.67.106.0/23",
                                "169.232.36.0/23",
                                "169.232.56.0/23",
                                "131.179.65.0/24",
                                "131.179.66.0/23",
                                "131.179.68.0/22",
                                "131.179.72.0/22",
                                "131.179.76.0/22",
                                "131.179.81.0/24",
                                "131.179.82.0/23",
                                "131.179.84.0/22",
                                "131.179.89.0/24",
                                "131.179.90.0/23",
                                "131.179.92.0/22",
                                "131.179.97.0/24",
                                "131.179.98.0/23",
                                "131.179.101.0/24",
                                "131.179.102.0/23",
                                "131.179.105.0/24",
                                "131.179.106.0/23",
                                "131.179.108.0/22",
                                "131.179.113.0/24",
                                "131.179.114.0/23",
                                "131.179.117.0/24",
                                "131.179.118.0/23",
                                "131.179.121.0/24",
                                "131.179.122.0/23",
                                "131.179.126.0/23",
                                "131.179.129.0/24",
                                "131.179.130.0/23",
                                "131.179.132.0/22",
                                "131.179.137.0/24",
                                "131.179.139.0/24",
                                "131.179.146.0/23",
                                "131.179.149.0/24",
                                "131.179.153.0/24",
                                "131.179.154.0/23",
                                "131.179.156.0/22",
                                "131.179.161.0/24",
                                "131.179.162.0/23",
                                "131.179.165.0/24",
                                "131.179.166.0/23",
                                "131.179.169.0/24",
                                "131.179.219.0/24",
                                "131.179.220.0/22",
                                "131.179.225.0/24",
                                "131.179.226.0/23",
                                "131.179.228.0/22",
                                "131.179.233.0/24",
                                "131.179.234.0/23",
                                "131.179.236.0/22",
                                "131.179.241.0/24"
                              ]
  sg_groups                 = null
  default_tag               = var.default_tag
}

module "allow_http_https_librarynetworks" {
  source                    = "git::https://github.com/UCLALibrary/aws_terraform_module_security_group.git"
  sg_name                   = "terraform-test-iiif-allow-librarynetworks"
  sg_description            = "Allow 80/443 ingress traffic to UCLA Library Networks"
  vpc_id                    = module.eks_vpc.vpc_main_id
  ingress_ports             = [80,443]
  ingress_allowed           = [
                                "164.67.217.0/24",
                                "164.67.40.0/24",
                                "164.67.29.0/24",
                                "164.67.152.0/25",
                                "164.67.152.128/25",
                                "164.67.222.0/24",
                                "164.67.16.0/24",
                                "164.67.17.0/24",
                                "164.67.19.128/25",
                                "164.67.150.0/24",
                                "164.67.151.0/24",
                                "164.67.33.0/24",
                                "164.67.18.128/25"
                              ]
  sg_groups                 = null
  default_tag               = var.default_tag
}


