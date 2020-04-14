resource "kubernetes_secret" "fester_env_secrets" {
  metadata {
    name = "fester-env-secrets"
    namespace = var.fester_deployment_namespace
  }

  type = "Opaque"

  data = {
    FESTER_S3_ACCESS_KEY = var.fester_deployment_s3_access_key
    FESTER_S3_SECRET_KEY = var.fester_deployment_s3_secret_key
  }
}
