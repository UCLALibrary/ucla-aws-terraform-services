variable "load_kubeconfig" {
  type = string
  default = "true"
}

variable "namespace" {
  type = string
  default = "kube-logging"
}

variable "image_pull_secrets" {
  type = string
  default = "registry-secret"
}

variable "dockercfg_server" {
  type = string
  default = "https://index.docker.io/v1/"
}

variable "dockercfg_username" {
  type = string
  default = "dockerhub_username"
}

variable "dockercfg_password" {
  type = string
  default = "dockerhub_password"
}

variable "dockercfg_email" {
  type = string
  default = "dockerhub_email"
}

variable "dockercfg_auth" {
  type = string
  default = "authvalue"
}

variable "fluentd_container_image_url" {
  type = string
  default = "fluent/fluentd"
}

variable "fluentd_container_image_version" {
  type = string
  default = "v1.11-debian-1"
}

variable "fluentd_container_port" {
  type = number
  default = 30000
}

variable "fluentd_container_env" {
  type = map(string)
  default = {
    FLUENT_SSL_KEY_PASSPHRASE = "yourpassphrase"
    FLUENT_FORWARD_HOST = "somehost"
    FLUENT_FORWARD_PORT = "30000"
    FLUENT_SOURCE_LISTEN_PORT = "30000"
  }
}

variable "fluentd_forward_mounts" {
  type = map(string)
  default = {
    fluentd-config-file = "fluent.conf"
    fluentd-forward-ca-crt = "fluentd-ca.crt"
    fluentd-forward-crt = "fluentd.crt"
    fluentd-forward-key = "fluentd.key"
  }
}

locals {
  dockercfg = {
    auths = {
      "${var.dockercfg_server}" = {
        username = var.dockercfg_username,
        password = var.dockercfg_password,
        email = var.dockercfg_email,
        auth = var.dockercfg_auth
      }
    }
  }

  fluentd_full_image_url = "${var.fluentd_container_image_url}:${var.fluentd_container_image_version}"
}
