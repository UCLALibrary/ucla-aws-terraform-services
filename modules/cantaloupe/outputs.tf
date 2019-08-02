output "http_listener_arn" {
  value = "${aws_lb_listener.cantaloupe_listener.arn}"
}

output "https_listener_arn" {
  value = "${aws_lb_listener.cantaloupe_listener_https.arn}"
}

