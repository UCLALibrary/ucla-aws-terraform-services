variable "load_kubeconfig" {
  type = string
  default = "true"
}

variable "namespace" {
  type = string
  default = "prod-iiif"
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

variable "cantaloupe_deployment_replicas" {
  type = number
  default = 1
}

variable "cantaloupe_deployment_container_image_url" {
  type = string
  default = "uclalibrary/cantaloupe-ucla"
}

variable "cantaloupe_deployment_container_image_version" {
  type = string
  default = "4.1.5"
}

variable "cantaloupe_deployment_container_port" {
  type = number
  default = 8182
}

variable "cantaloupe_deployment_container_env" {
  type = map(string)
  default = {
    CANTALOUPE_ENDPOINT_ADMIN_ENABLED = "true"
    JAVA_HEAP_SIZE="1g"
  }
}

variable "cantaloupe_deployment_s3_access_key" {
  type = string
  default = "accesskey"
}

variable "cantaloupe_deployment_s3_secret_key" {
  type = string
  default = "secretkey"
}

variable "cantaloupe_deployment_admin_password" {
  type = string
  default = "myadminpassword"
}

variable "prod_sinai_iiif_tls_crt" {
  type = string
  default = "base64encodedval"
}

variable "prod_sinai_iiif_tls_key" {
  type = string
  default = "base64encodedval"
}

variable "cantaloupe_deployment_cpu_limit" {
  type = string
  default = "1"
}

variable "cantaloupe_deployment_cpu_request" {
  type = string
  default = "0.5"
}

variable "cantaloupe_deployment_memory_limit" {
  type = string
  default = "1024Mi"
}

variable "cantaloupe_deployment_memory_request" {
  type = string
  default = "128Mi"
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
}
