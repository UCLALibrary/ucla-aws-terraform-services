#### Variable for test-iiif
image_pull_secrets = "services-dockerhub-creds"
dockercfg_server = "https://index.docker.io/v1/"

#### Variables for Cantaloupe environment
cantaloupe_deployment_replicas = 2
cantaloupe_deployment_container_image_url = "uclalibrary/cantaloupe-ucla"
cantaloupe_deployment_container_image_version = "4.1.5"
cantaloupe_deployment_container_port = 8182
cantaloupe_deployment_container_env = {
  CANTALOUPE_ENDPOINT_ADMIN_ENABLED = "true"
  CANTALOUPE_CACHE_SERVER_DERIVATIVE_ENABLED = "true"
  CANTALOUPE_CACHE_SERVER_DERIVATIVE = "S3Cache"
  CANTALOUPE_CACHE_SERVER_DERIVATIVE_TTL_SECONDS = "0"
  CANTALOUPE_CACHE_SERVER_PURGE_MISSING = "true"
  CANTALOUPE_PROCESSOR_SELECTION_STRATEGY = "ManualSelectionStrategy"
  CANTALOUPE_MANUAL_PROCESSOR_JP2 = "KakaduNativeProcessor"
  CANTALOUPE_S3CACHE_ENDPOINT = "s3.us-west-2.amazonaws.com"
  CANTALOUPE_S3CACHE_BUCKET_NAME = "prod-sinai-cantaloupe-iiif-cache"
  CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_BUCKET_NAME = "prod-sinai-cantaloupe-iiif-source"
  CANTALOUPE_S3SOURCE_ENDPOINT = "s3.us-west-2.amazonaws.com"
  CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX = ".jpx"
  CANTALOUPE_SOURCE_STATIC = "S3Source"
  CANTALOUPE_MAX_PIXELS = 0
  JAVA_HEAP_SIZE = "10g"
  DELEGATE_URL = "https://raw.githubusercontent.com/UCLALibrary/cantaloupe-delegate/master/lib/delegates.rb"
}
cantaloupe_deployment_cpu_limit = "6"
cantaloupe_deployment_cpu_request = "0.5"
cantaloupe_deployment_memory_limit = "10Gi"
cantaloupe_deployment_memory_request = "1Gi"
