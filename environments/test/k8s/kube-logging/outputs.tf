output "fluentd_forward_cluster_ip" {
  value = data.external.fluentd_service_cluster_ip.result.ip
}

output "fluentd_forward_port" {
  value = lookup(var.fluentd_container_env, "FLUENT_FORWARD_PORT", "12225")
}
