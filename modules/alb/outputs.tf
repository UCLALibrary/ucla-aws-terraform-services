output "alb_main_id" {
  value = "${aws_lb.alb_main.id}"
}

output "alb_main_sg_id" {
  value = "${aws_security_group.alb_access.id}"
}
