terraform {
  required_version = "~> 0.12.0"
  backend "remote" {}
}

provider "aws" {
  region           = "us-west-2"
}

resource "aws_vpc" "eks_network" {
  cidr_block       = "172.10.0.0/16"

  tags             = {
    Name           = "EKS"
  }
}

resource "aws_subnet" "eks_subnets" {
  vpc_id           = "${aws_vpc.eks_network}"
  cidr_block       = "172.10.10.0/24"

  tags             = {
    Name           = "EKS"
  }
}

resource "aws_key_pair" "deploy_key" {
  key_name         = "deploy-key"
  public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTQ0YbsCQxfiUphlcardRaR3vi7fPJ4mQXFm1BfUHR+vD/s35WqbGAAXolWpVBaOXk+ix+lU5aWf0o3Op6dw7SQjYzuiRO3RMLcYBuZ6Yg1NxAthqc841XSZWCwSWc+SApROa7cVHgIQm47MUnGQGkbN0RRi7j3b0FMRif8Aga9M8VIqYw7JmUf6lZrYPGIno4r7akpYtnlMCGcKNuOu+iXFYuImzzHNpWCn6IzZVSmPYniu6KvczJv1CUNixrck7yjemZpWUDJvP7FkSsNx5ImQn4DHf5IvgQJ54htYB21mo1elCyCnlHv6SffoaXwVBM6leU5ytvGFijUDldC+4x"
}

data "aws_ami" "centos" {
  most_recent      = true

  filter {
    name           = "source"
    values         = ["amazon/amzn2-ami-hvm-2.0*"]
  }

  filter {
    name           = "virtualization-type"
    values         = "hvm"
  }

  # AWS Owned AMI ID
  owners           = ["137112412989"]
}
resource "aws_instance" "eks_bastion" {
  ami              = "${data.aws_ami.centos}"
  instance_type    = "t3.micro"
  subnet_id        = "${aws_subnet.eks_subnets.id}"
  key_name         = "${aws_key_pair.deploy_key.name}"

  tags             = {
    Name           = "EKS"
  }
}
