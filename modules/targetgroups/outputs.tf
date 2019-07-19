output "cantaloupe_target_group_arn" {
  value = "${aws_lb_target_group.cantaloupe_tg.id}"
}

output "manifeststore_target_group_arn" {
  value = "${aws_lb_target_group.manifeststore_tg.id}"
}

