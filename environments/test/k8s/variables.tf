### Kubernetes Provider Settings
variable "load_kubeconfig" {
  type = string
  default = "true"
}

### Cantaloupe Deployment Settings
variable "cantaloupe_deployment_name" {
  type = string
  default = "cantaloupe"
}

variable "cantaloupe_deployment_namespace" {
  type = string
  default = "cantaloupe-namespace"
}

variable "cantaloupe_deployment_replicas" {
  type = number
  default = 1
}

variable "cantaloupe_deployment_labels" {
  type = map(string)
  default = {
    app = "cantaloupe_deployment"
  }
}

variable "cantaloupe_deployment_image_pull_secrets" {
  type = string
  default = "registry-secret"
}

variable "cantaloupe_deployment_container_image_url" {
  type = string
  default = "uclalibrary/cantaloupe-ucla"
}

variable "cantaloupe_deployment_container_image_version" {
  type = string
  default = "4.1.4"
}


variable "cantaloupe_deployment_container_name" {
  type = string
  default = "cantaloupe"
}

variable "cantaloupe_deployment_container_image_pull_policy" {
  type = string
  default = "Always"
}

variable "cantaloupe_deployment_container_port" {
  type = number
  default = 1
}

###############################################################################################################
# The following default variables represent a subset of environment variables to override the defaults.
# It assumes configuring an S3 bucket for cache and as a source. Please override the map in a external
# tfvars file if customization is desired.
# JAVA_HEAP_SIZE is also import as it determines allowed heap space to run on the JVM.
# The accepted values are "#g"
#
# Depending on your setup, these environment variables should be inheritted from an external source.
# CANTALOUPE_S3CACHE_ACCESS_KEY_ID
# CANTALOUPE_S3CACHE_SECRET_KEY
# CANTALOUPE_S3SOURCE_ACCESS_KEY_ID
# CANTALOUPE_S3SOURCE_SECRET_KEY
###############################################################################################################
variable "cantaloupe_deployment_container_env" {
  type = map(string)
  default = {
    CANTALOUPE_ENDPOINT_ADMIN_ENABLED = "true"
    CANTALOUPE_ENDPOINT_ADMIN_SECRET = "examplepassword"
    CANTALOUPE_CACHE_SERVER_DERIVATIVE_ENABLED = "false"
    CANTALOUPE_CACHE_SERVER_DERIVATIVE = "S3Cache"
    CANTALOUPE_CACHE_SERVER_DERIVATIVE_TTL_SECONDS = "3600"
    CANTALOUPE_CACHE_SERVER_PURGE_MISSING = "true"
    CANTALOUPE_PROCESSOR_SELECTION_STRATEGY = "ManualSelectionStrategy"
    CANTALOUPE_MANUAL_PROCESSOR_JP2 = "KakaduNativeProcessor"
    CANTALOUPE_S3CACHE_ACCESS_KEY_ID = "youraccesskeyid"
    CANTALOUPE_S3CACHE_SECRET_KEY = "yoursecretkey"
    CANTALOUPE_S3CACHE_ENDPOINT = "s3.us-west-2.amazonaws.com"
    CANTALOUPE_S3CACHE_BUCKET_NAME = "yourcachebucket"
    CANTALOUPE_S3SOURCE_BUCKET_NAME = "yoursourcebucket"
    CANTALOUPE_S3SOURCE_ACCESS_KEY_ID = "youraccesskeyid"
    CANTALOUPE_S3SOURCE_SECRET_KEY = "yoursecretkey"
    CANTALOUPE_S3SOURCE_ENDPOINT = "s3.us-west-2.amazonaws.com"
    CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX = ".jpx"
    CANTALOUPE_SOURCE_STATIC = "S3Source"
    JAVA_HEAP_SIZE = "4g"

  }
}

locals {
  cantaloupe_deployment_container_image_full_url = "${var.cantaloupe_deployment_container_image_url}:${var.cantaloupe_deployment_container_image_version}"
}
