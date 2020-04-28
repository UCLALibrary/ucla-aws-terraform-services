data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_main_cidr_block

  tags = var.vpc_tag
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = var.vpc_tag
}

resource "aws_subnet" "eks_prod_public" {
  count                   = length(var.eks_prod_public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.eks_prod_public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.vpc_tag, var.prod_eks_public_vpc_tag)
}

resource "aws_subnet" "eks_test_public" {
  count                   = length(var.eks_test_public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.eks_test_public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.vpc_tag, var.test_eks_public_vpc_tag)
}

resource "aws_subnet" "eks_prod_private" {
  count                   = length(var.eks_prod_private_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.eks_prod_private_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.vpc_tag, var.prod_eks_private_vpc_tag)
}

resource "aws_subnet" "eks_test_private" {
  count                   = length(var.eks_test_private_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.eks_test_private_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.vpc_tag, var.prod_eks_private_vpc_tag)
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

resource "aws_route_table" "public_igw_egress" {
  vpc_id                  = aws_vpc.main.id
  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.igw.id
  }

  tags = var.vpc_tag
}

resource "aws_route_table" "iiif_routes" {
  vpc_id = aws_vpc.main.id

  dynamic route {
    for_each = var.iiif_nat_egress_list
    content {
      cidr_block = route.value
      nat_gateway_id = aws_nat_gateway.ngw.id
    }
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = var.vpc_tag
}

resource "aws_route_table" "nat_egress_global" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = var.vpc_tag
}

resource "aws_route_table_association" "route_public_subnets_igw" {
  for_each = toset(concat(aws_subnet.eks_prod_public.*.id, aws_subnet.eks_test_public.*.id, aws_subnet.gp_public.*.id))
  subnet_id = each.key
  route_table_id = aws_route_table.public_igw_egress.id
}

resource "aws_route_table_association" "attach_eks_nodegroup_iiif_routes" {
  for_each = toset(concat(aws_subnet.eks_prod_private.*.id, aws_subnet.eks_test_private.*.id, aws_subnet.lambda_prod_private.*.id, aws_subnet.lambda_test_private.*.id))
  subnet_id = each.key
  route_table_id = aws_route_table.iiif_routes.id
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

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-west-2.s3"

  tags = var.vpc_tag
}
