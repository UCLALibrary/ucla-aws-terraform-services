data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_main_cidr_block
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "newmain"
  }
}

resource "aws_subnet" "eks_prod_public" {
  count                   = length(var.eks_prod_public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.eks_prod_public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "eks_test_public" {
  count                   = length(var.eks_test_public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.eks_test_public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "eks_prod_private" {
  count                   = length(var.eks_prod_private_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.eks_prod_private_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "eks_test_private" {
  count                   = length(var.eks_test_private_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.eks_test_private_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "lambda_prod_private" {
  count                   = length(var.lambda_prod_private_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.lambda_prod_private_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
}

resource "aws_subnet" "lambda_test_private" {
  count                   = length(var.lambda_test_private_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.lambda_test_private_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
}

resource "aws_subnet" "gp_public" {
  count                   = length(var.gp_public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.gp_public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.gp_public[0].id
}

resource "aws_security_group" "ucla_vpn" {
  name = "ucla_vpn_list"
  description = "A list of UCLA VPN networks"
  vpc_id = aws_vpc.main.id

  dynamic ingress {
    for_each = var.public_http_ports
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = var.uclavpn_ingress_allowed
    }
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ucla_library" {
  name = "ucla_library_list"
  description = "A list of UCLA Library networks"
  vpc_id = aws_vpc.main.id

  dynamic ingress {
    for_each = var.public_http_ports
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = var.uclalibrary_ingress_allowed
    }
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
