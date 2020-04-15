resource "kubernetes_ingress" "test-iiif" {
  metadata {
    name = "test-iiif"
    namespace = "test-iiif"
    annotations = {
      "nginx.ingress.kubernetes.io/use-regex" = "true"
      "nginx.ingress.kubernetes.io/enable-cors" = "true"
      "nginx.ingress.kubernetes.io/ssl-passthrough" = "false"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-methods" = "GET,HEAD,PUT,POST,DELETE"
    }
  }

  spec {
    tls {
      secret_name = "test-iiif-tls"
      hosts = ["test-iiif.library.ucla.edu"]
    }

    rule {
      http {
        path {
          path = "/fester[/]?.*"
          backend {
            service_name = var.fester_deployment_container_name
            service_port = 8888
          }
        }

        path {
          path = "/collections[/]?.*"
          backend {
            service_name = var.fester_deployment_container_name
            service_port = 8888
          }
        }

        path {
          path = "/status/fester"
          backend {
            service_name = var.fester_deployment_container_name
            service_port = 8888
          }
        }

        path {
          path = "/.*/manifest"
          backend {
            service_name = var.fester_deployment_container_name
            service_port = 8888
          }
        }

        path {
          backend {
            service_name = var.cantaloupe_deployment_container_name
            service_port = 8182
          }
        }
      }
    }
  }
}
