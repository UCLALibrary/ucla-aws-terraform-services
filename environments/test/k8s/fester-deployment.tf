resource "kubernetes_deployment" "fester" {
  metadata {
    name = var.fester_deployment_name
    namespace = var.fester_deployment_namespace
    labels = var.fester_deployment_labels
  }

  spec {
    replicas = var.fester_deployment_replicas

    selector {
      match_labels = var.fester_deployment_labels
    }

    template {
      metadata {
        labels = var.fester_deployment_labels
      }

      spec {
        image_pull_secrets {
          name = var.image_pull_secrets
        }

        container {
          image = local.fester_deployment_container_image_full_url
          name  = var.fester_deployment_container_name
          image_pull_policy = var.fester_deployment_container_image_pull_policy

          port {
            container_port = var.fester_deployment_container_port
          }

          dynamic "env" {
            for_each = var.fester_deployment_container_env

            content {
              name = env.key
              value = env.value
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.fester_env_secrets.metadata[0].name
            }
          }

          liveness_probe {
            http_get {
              path = "/fester/status"
              port = var.fester_deployment_container_port
            }

            initial_delay_seconds = 15
            period_seconds        = 20
          }

          readiness_probe {
            tcp_socket {
              port = var.fester_deployment_container_port
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}
