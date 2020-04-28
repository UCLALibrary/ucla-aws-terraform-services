resource "kubernetes_service" "nlb" {
  metadata {
    name = "ingress-nginx"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/name" = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }

    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
    }
  }

  spec {
    external_traffic_policy = "Local"
    type = "LoadBalancer"

    selector = {
      "app.kubernetes.io/name" = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }

    port {
      name = "http"
      port = 80
      target_port = "http"
    }
    port {
      name = "https"
      port = 443
      target_port = "https"
    }
  }
}
