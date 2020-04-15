resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "dockerhub_registry" {
  metadata {
    name = var.image_pull_secrets
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = "${jsonencode(local.dockercfg)}"
  }

  type = "kubernetes.io/dockerconfigjson"
}

module "cantaloupe" {
  source = "git::https://github.com/UCLALibrary/terraform-kubernetes-cantaloupe.git?ref=IIIF-773"
  cantaloupe_deployment_namespace = kubernetes_namespace.namespace.metadata[0].name
  cantaloupe_deployment_replicas = var.cantaloupe_deployment_replicas
  image_pull_secrets = kubernetes_secret.dockerhub_registry.metadata[0].name
  cantaloupe_deployment_container_image_url = var.cantaloupe_deployment_container_image_url
  cantaloupe_deployment_container_image_version = var.cantaloupe_deployment_container_image_version
  cantaloupe_deployment_container_port = var.cantaloupe_deployment_container_port
  cantaloupe_deployment_container_env = var.cantaloupe_deployment_container_env
  cantaloupe_deployment_s3_access_key = var.cantaloupe_deployment_s3_access_key
  cantaloupe_deployment_s3_secret_key = var.cantaloupe_deployment_s3_secret_key
  cantaloupe_deployment_admin_password = var.cantaloupe_deployment_admin_password
}

module "fester" {
  source = "git::https://github.com/UCLALibrary/terraform-kubernetes-fester.git?ref=IIIF-773"
  fester_deployment_namespace = kubernetes_namespace.namespace.metadata[0].name
  fester_deployment_replicas = var.fester_deployment_replicas
  image_pull_secrets = kubernetes_secret.dockerhub_registry.metadata[0].name
  fester_deployment_container_image_url = var.fester_deployment_container_image_url
  fester_deployment_container_image_version = var.fester_deployment_container_image_version
  fester_deployment_container_port = var.fester_deployment_container_port
  fester_deployment_container_env = var.fester_deployment_container_env
  fester_deployment_s3_access_key = var.fester_deployment_s3_access_key
  fester_deployment_s3_secret_key = var.fester_deployment_s3_secret_key
}

resource "kubernetes_ingress" "test-iiif" {
  metadata {
    name = "test-iiif"
    namespace = kubernetes_namespace.namespace.metadata[0].name
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
            service_name = module.fester.fester_service_name
            service_port = module.fester.fester_service_port
          }
        }

        path {
          path = "/collections[/]?.*"
          backend {
            service_name = module.fester.fester_service_name
            service_port = module.fester.fester_service_port
          }
        }

        path {
          path = "/status/fester"
          backend {
            service_name = module.fester.fester_service_name
            service_port = module.fester.fester_service_port
          }
        }

        path {
          path = "/.*/manifest"
          backend {
            service_name = module.fester.fester_service_name
            service_port = module.fester.fester_service_port
          }
        }

        path {
          backend {
            service_name = module.cantaloupe.cantaloupe_service_name
            service_port = module.cantaloupe.cantaloupe_service_port
          }
        }
      }
    }
  }
}