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
  public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqvxpnmmXqTwOwO4mQcHcHjFeL9fEa7R8Gohm5aR5ifSITz2IYS7AJ3vubWwRd3Xkbv/aDBibQ5LcKDxVGqK78NW5B6DeQ5iVWLAsbSK0ugFMW2iD5i8VGTzaEHNqIQcWFHP4yZP3QTON1P1jUqTtLP3Rq8VXQZCbwfIrF/ce9TR/dT1qOuYVNM7+0BKZ8xus6xttPQUgbw/miogyx6geSxDceTb/TIoFHIdNKcwmqZV1jLFJvb4nDKc6F8CS7lJpfJ58tnug3JbJWQmbwWw26cDdXnEKhNliizxA7yhI0g5tO7O1cRkR8wp+8V5hQUljRFoj18WuyZ6SdAYU3KiBf"
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

resource "aws_iam_role" "iam_for_eks" {
  name = "iam_for_eks"
  assume_role_policy = "${data.aws_iam_policy_document.eks_assume_policy_document.json}"
} 

resource "aws_iam_role_policy_attachment" "eks_attach_service_policy" {
  role = "${aws_iam_role.iam_for_eks.name}"
  policy_arn = "${var.eks_iam_policy_attachment_service_arn}"
}

resource "aws_iam_role_policy_attachment" "eks_attach_cluster_policy" {
  role = "${aws_iam_role.iam_for_eks.name}"
  policy_arn = "${var.eks_iam_policy_attachment_cluster_arn}"
}

resource "aws_iam_role" "iam_for_eks_node_group" {
  name = "eks_node_group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "iam_for_eks_node_group-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.iam_for_eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "iam_for_eks_node_group-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.iam_for_eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "iam_for_eks_node_group-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.iam_for_eks_node_group.name
}

resource "aws_eks_cluster" "eks_cluster" {
  name = "eks_cluster"
  role_arn = "${aws_iam_role.iam_for_eks.arn}"
  
  vpc_config {
    subnet_ids = "${aws_subnet.eks_subnets[*].id}"
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name = "${aws_eks_cluster.eks_cluster.name}"
  node_group_name = "eks_node_group"
  node_role_arn = "${aws_iam_role.iam_for_eks_node_group.arn}"
  subnet_ids = "${aws_subnet.eks_subnets[*].id}"

  scaling_config {
    desired_size = "${var.node_desired_size}"
    max_size = "${var.node_max_size}"
    min_size = "${var.node_min_size}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.iam_for_eks_node_group-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.iam_for_eks_node_group-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.iam_for_eks_node_group-AmazonEKSWorkerNodePolicy
  ]
}