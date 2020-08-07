### Create kube-logging namespace to run fluentd local endpoint
resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

### Create secret to maintain Dockerhub registry to access private container images if necessary
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

### Create Fluentd Daemonset and expose port 30000 as local endpoint.
### This setup is used to forward to an external Fluentd Aggregator.
### Encryption via SSL/TLS is required for this setup to ensure encryption in transit.
### The following ConfigMaps must be defined:
### fluentd-config-file
###   - Main fluentd config file
### fluentd-forward-ca-crt
###   - Self Signed CA certificate with client and server certificates signed
### fluentd-forward-crt
###   - Self signed client certificate
### fluentd-forward-key
###   - Keypair assigned to self signed certificate
resource "kubernetes_daemonset" "fluentd" {
  metadata {
    name = "fluentd"
    namespace = var.namespace
    labels = {}
      k8s-app = "fluentd-logging"
    }
  }

  spec {
    selector {
      match_labels = {
        name = "fluentd-forward"
      }
    }

    template {
      metadata {
        labels = {
          name = "fluentd-forward"
        }
      }
    }

    spec {
      ### To properly set permissions in ConfigMap mounted files, the files mounted will be chgrp'd to the GID specified in fs_group.
      ### There isn't a built-in mechanism to change the owner of a file. The combination of granting group access with proper permissions sets are used instead.
      security_context {
        fs_group = 999
      }

      tolerations {
        key = "node-role.kubernetes.io/master"
        effect = "NoSchedule"
      }

      containers {
        name = "fluentd"
        image = local.fluentd_full_image_url

        port {
          container_port = 30000
          host_port = 30000
        }

        dynamic "env" {
          for_each = var.fluentd_env

          content {
            name = env.key
            value = env.value
          }
        }

        resources {
          limits {
            memory = "200Mi"
          }

          requests {
            cpu = "100Mi"
            memory = "200Mi"
          }
        }

        volume {
          config_map {
            name = "fluentd-config-file"
            items {
              key = fluent.conf
              path = fluent.conf
              mode = 0660
            }
          }
        }

        volume {
          config_map {
            name = "fluentd-forward-ca-crt"
            items {
              key = fluentd-ca.crt
              path = fluentd-ca.crt
            }
          }
        }

        volume {
          config_map {
            name = "fluentd-forward-crt"
            items {
              key = fluentd.crt
              path = fluentd.crt
            }
          }
        }

        volume {
          config_map {
            name = "fluentd-forward-key"
            items {
              key = fluentd.key
              path = fluentd.key
              mode = 0660
            }
          }
        }

        dynamic "volume_mount" {
          for_each = var.fluentd_forward_mounts

          content {
            name = volume_mount.key
            mount_path = volume_mount.value
          }
        }

        termination_grace_period_seconds = 30
      }
    }
  }
}
