resource "aws_alb" "cantaloupe_alb" {
  name            = "cantaloupe-alb"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.cantaloupe_alb_ecs.id}"]
}

resource "aws_alb_target_group" "cantaloupe_tg" {
  name        = "cantaloupe-tg"
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.main.id}"
  target_type = "ip"
  port        = 80
}

resource "aws_alb_listener" "cantaloupe-fe" {
  load_balancer_arn = "${aws_alb.cantaloupe_alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.cantaloupe_tg.id}"
    type             = "forward"
  }
}