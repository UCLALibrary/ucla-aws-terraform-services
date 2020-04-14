### Kubernetes Provider Settings
variable "load_kubeconfig" {
  type = string
  default = "true"
}

variable "image_pull_secrets" {
  type = string
  default = "registry-secret"
}
