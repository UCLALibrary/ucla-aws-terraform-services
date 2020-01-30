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
  map_public_ip_on_launch = "true"

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

resource "aws_route_table_association" "eks_route_global_table" {
  for_each = toset(aws_subnet.eks_subnets.*.id)
  subnet_id = each.key
  route_table_id = "${aws_route_table.eks_global_route.id}"

  depends_on = [
    aws_subnet.eks_subnets
  ]
}

resource "aws_key_pair" "deploy_key" {
  key_name         = "deploy-key"
  public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkwazJbdOiBSp3Ylz6X6ltkQ7HgmEU9fimotzrBWGohO7ss73bqPjWTR4nLPVGcuyLG51i937YSijvbG9QD1S7D4dN780+SB4UfX4cRKNYIw2XCGwfsWYHOGB8Gl/PRtPx8PA5DST4qy+dztPE2zVzAt6ChIw1jxSocdbJ9gd4IF7U6jK3ziywpFMhDfLs/vlx98Fm521xYWtefaT1+bb4a7/YdE++6KA/sbk6Dg3rzlfHHmpWJMromL/wHnIj/njBW2LlTIIkvJY+gLbVYQ3QDrbxbKa5iHaBTI7P6iRkJhkssE4VEpm/y79XD11EZd8E2GsAs2WjnTfynIN13Reh"
}


resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "Allow SSH access from worldwide"
  vpc_id = "${aws_vpc.eks_network.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EKS"
  }
}

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

resource "aws_instance" "eks_bastion" {
  ami              = "${data.aws_ami.amazon_linux.id}"
  instance_type    = "t3.micro"
  subnet_id        = "${aws_subnet.eks_subnets[0].id}"
  key_name         = "${aws_key_pair.deploy_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]

  tags             = {
    Name           = "EKS"
  }
}

data "aws_iam_policy_document" "eks_assume_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
 
    principals {
      type = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "template_file" "iam_policy_permissions_for_lambda" {
  template = "${file("${path.module}/templates/iam_policy.json.tpl")}"
  vars = {
    s3_list_of_buckets = "${jsonencode(var.s3_iam_allowed_resources)}"
    s3_permissions = "${jsonencode(var.s3_iam_allowed_actions)}"
    cloudwatch_permissions = "${jsonencode(var.cloudwatch_iam_allowed_actions)}"
  }
}

resource "aws_iam_role" "iam_for_eks" {
  name = "iam_for_eks"
  assume_role_policy = "${data.aws_iam_policy_document.eks_assume_policy_document}"
} 

resource "aws_eks_cluster" "eks_cluster" {
  name = "eks_cluster"
  role_arn = "${var.aws_iam_role.iam_for_eks.role_arn}"
  
  vpc_config {
    subnet_ids = [
      toset(aws_subnets.eks_subnets.*.id)
    ]
  }
}