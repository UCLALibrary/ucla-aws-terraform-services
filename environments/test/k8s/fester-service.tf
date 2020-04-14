resource "kubernetes_service" "fester" {
  metadata {
    name = var.fester_deployment_name
    namespace = var.fester_deployment_namespace
  }

  spec {
    type = "NodePort"

    selector = {
      app = var.fester_deployment_name
    }

    port {
      port = var.fester_deployment_container_port
      target_port = var.fester_deployment_container_port
      protocol = "TCP"
    }
  }
}
