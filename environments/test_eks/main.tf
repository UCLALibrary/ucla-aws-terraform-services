terraform {
  required_version = "~> 0.12.0"
#  backend "remote" {}
  backend "local" {
    path           = "terraform.tfstate"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
  profile          = "${var.aws_profile}"
  region           = "${var.aws_region}"
}

resource "aws_vpc" "eks_network" {
  cidr_block       = "${var.eks_vpc_network}"

  tags             = {
    Name           = "EKS"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = "${aws_vpc.eks_network.id}"

  tags = {
    Name = "EKS"
  }
}

#Example: 172.10.100.0/24
resource "aws_subnet" "eks_subnets" {
  count = length(var.eks_subnets)

  vpc_id           = "${aws_vpc.eks_network.id}"
  availability_zone = "${local.hosted_az[count.index % length(local.hosted_az)]}"
  cidr_block       = "${var.eks_subnets[count.index]}"

  tags             = {
    Name           = "EKS"
  }
}

resource "aws_route_table" "eks_global_route" {
  vpc_id = "${aws_vpc.eks_network.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eks_igw.id}"
  }

  tags = {
    Name = "EKS"
  }
}
#  route_table_id = "${aws_route_table.eks_global_route.id}"

resource "aws_key_pair" "deploy_key" {
  key_name         = "deploy-key"
  public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTQ0YbsCQxfiUphlcardRaR3vi7fPJ4mQXFm1BfUHR+vD/s35WqbGAAXolWpVBaOXk+ix+lU5aWf0o3Op6dw7SQjYzuiRO3RMLcYBuZ6Yg1NxAthqc841XSZWCwSWc+SApROa7cVHgIQm47MUnGQGkbN0RRi7j3b0FMRif8Aga9M8VIqYw7JmUf6lZrYPGIno4r7akpYtnlMCGcKNuOu+iXFYuImzzHNpWCn6IzZVSmPYniu6KvczJv1CUNixrck7yjemZpWUDJvP7FkSsNx5ImQn4DHf5IvgQJ54htYB21mo1elCyCnlHv6SffoaXwVBM6leU5ytvGFijUDldC+4x"
}

# TODO: Create security group to allow SSH from list of IPs

data "aws_ami" "amazon_linux" {
  most_recent      = true

  filter {
    name           = "manifest-location"
    values         = ["amazon/amzn2-ami-hvm-2.0*"]
  }

  filter {
    name           = "virtualization-type"
    values         = ["hvm"]
  }

  # AWS Owned AMI ID
  owners           = ["137112412989"]
}

resource "random_shuffle" "az" {
  input = "${aws_subnet.eks_subnets[count.index].id}"
  result_count = 2
}

#resource "aws_instance" "eks_bastion" {
#  ami              = "${data.aws_ami.amazon_linux.id}"
#  instance_type    = "t3.micro"
#  subnet_id        = "${random_shuffle.az.result}"
#  key_name         = "${aws_key_pair.deploy_key.key_name}"
#
#  tags             = {
#    Name           = "EKS"
#  }
#}
