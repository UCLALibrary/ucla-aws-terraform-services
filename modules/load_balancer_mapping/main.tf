resource "aws_lb_listener" "http_listener" {
   load_balancer_arn = "${var.alb_main_id}"
   port              = "80"
   protocol          = "HTTP"

   default_action {
     target_group_arn = "${var.cantaloupe_target_group_arn}"
     type             = "forward"
   }
}

