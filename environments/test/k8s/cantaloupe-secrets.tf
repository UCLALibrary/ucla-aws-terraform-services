resource "kubernetes_secret" "cantaloupe_env_secrets" {
  metadata {
    name = "cantaloupe-env-secrets"
    namespace = var.cantaloupe_deployment_namespace
  }

  type = "Opaque"

  data = {
    CANTALOUPE_S3CACHE_ACCESS_KEY_ID = var.cantaloupe_deployment_s3_access_key
    CANTALOUPE_S3CACHE_SECRET_KEY = var.cantaloupe_deployment_s3_secret_key
    CANTALOUPE_S3SOURCE_ACCESS_KEY_ID = var.cantaloupe_deployment_s3_access_key
    CANTALOUPE_S3SOURCE_SECRET_KEY = var.cantaloupe_deployment_s3_secret_key
    CANTALOUPE_ENDPOINT_ADMIN_SECRET = var.cantaloupe_deployment_admin_password
  }
}
