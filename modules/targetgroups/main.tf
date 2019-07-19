resource "aws_lb_target_group" "cantaloupe_tg" {
  name        = "${var.app_name}-cantaloupe-tg"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_main_id}"
  target_type = "ip"
  port        = "${var.cantaloupe_app_port}"
}

resource "aws_lb_target_group" "manifeststore_tg" {
  name        = "${var.app_name}-manifeststore-tg"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_main_id}"
  target_type = "ip"
  port        = "${var.manifeststore_app_port}"
}

