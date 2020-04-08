provider "kubernetes" {
  load_config_file = var.load_kubeconfig
}

resource "kubernetes_deployment" "cantaloupe" {
  metadata {
    name = var.cantaloupe_deployment_name
    namespace = var.cantaloupe_deployment_namespace
    labels = var.cantaloupe_deployment_labels
  }

  spec {
    replicas = var.cantaloupe_deployment_replicas

    selector {
      match_labels = cantaloupe_deployment_labels
    }

    template {
      metadata {
        labels = var.cantaloupe_deployment_labels
      }

      spec {
        container {
          image = var.cantaloupe_deployment_container_image
          name  = var.cantaloupe_deployment_container_name
          image_pull_policy = var.cantaloupe_deployment_container_image_pull_policy

          port {
            containerPort = var.cantaloupe_deployment_container_port
          }

          liveness_probe {
            http_get {
              path = "/iiif/2"
              port = var.cantaloupe_deployment_container_port
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}
