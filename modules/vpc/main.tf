# Populate state file with AZ info.

data "aws_availability_zones" "available" {}

#############################################################################################################
# Create VPC network
#############################################################################################################
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr_block}"
}

#############################################################################################################
# Create public subnet to attach Internet Gateway route
#############################################################################################################
resource "aws_subnet" "public" {
  count                   = "${var.subnet_count}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 8, var.subnet_int + count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_network"
  }
}

#############################################################################################################
# Attach internet gateway to created VPC
#############################################################################################################
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

#############################################################################################################
# Set main route table for VPC to Internet Gateway
#############################################################################################################
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}
