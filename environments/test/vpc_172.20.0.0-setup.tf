# Populate state file with AZ info.
data "aws_availability_zones" "available" {}

#############################################################################################################
# Create VPC network 172.20.0.0/16
#############################################################################################################
resource "aws_vpc" "main" {
  cidr_block = "172.20.0.0/16"
}

#############################################################################################################
# Create public subnet to attach Internet Gateway route
# 172.20.30.0/24
#############################################################################################################
resource "aws_subnet" "public" {
  count                   = 1
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 30 + count.index)}"
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
.
#############################################################################################################
# Set main route table for VPC to Internet Gateway
#############################################################################################################
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}