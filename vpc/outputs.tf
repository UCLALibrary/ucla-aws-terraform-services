output "vpc_main_id" {
  value = aws_vpc.main.id
}

output "eks_prod_public_subnet_ids" {
  value = aws_subnet.eks_prod_public.*.id
}

output "eks_test_public_subnet_ids" {
  value = aws_subnet.eks_test_public.*.id
}

output "eks_prod_private_subnet_ids" {
  value = aws_subnet.eks_prod_private.*.id
}

output "eks_private_public_subnet_ids" {
  value = aws_subnet.eks_test_private.*.id
}

output "lambda_prod_private_subnet_ids" {
  value = aws_subnet.lambda_prod_private.*.id
}

output "lambda_test_public_subnet_ids" {
  value = aws_subnet.lambda_test_private.*.id
}

output "gp_public_subnet_ids" {
  value = aws_subnet.gp_public.*.id
}

output "nat_eip_public_ip" {
  value = aws_nat_gateway.ngw.public_ip
}

output "sg_uclavpn_id" {
  value = aws_security_group.ucla_vpn.id
}

output "sg_uclavpn_arn" {
  value = aws_security_group.ucla_vpn.arn
}

output "sg_uclavpn_name" {
  value = aws_security_group.ucla_vpn.name
}

output "sg_uclalibrary_id" {
  value = aws_security_group.ucla_library.id
}

output "sg_uclalibrary_arn" {
  value = aws_security_group.ucla_library.arn
}

output "sg_uclalibrary_name" {
  value = aws_security_group.ucla_library.name
}
