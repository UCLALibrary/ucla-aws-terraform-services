resource "kubernetes_service" "cantaloupe" {
  metadata {
    name = var.cantaloupe_deployment_name
    namespace = var.cantaloupe_deployment_namespace
  }

  spec {
    type = "NodePort"

    selector = {
      app = var.cantaloupe_deployment_name
    }

    port {
      port = var.cantaloupe_deployment_container_port
      target_port = var.cantaloupe_deployment_container_port
      protocol = "TCP"
    }
  }
}
