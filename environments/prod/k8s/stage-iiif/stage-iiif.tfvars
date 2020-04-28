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
  CANTALOUPE_S3CACHE_BUCKET_NAME = "stage-iiif-cantaloupe-cache"
  CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_BUCKET_NAME = "prod-cantaloupe-iiif-source"
  CANTALOUPE_S3SOURCE_ENDPOINT = "s3.us-west-2.amazonaws.com"
  CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX = ".jpx"
  CANTALOUPE_SOURCE_STATIC = "S3Source"
  CANTALOUPE_MAX_PIXELS = 0
  JAVA_HEAP_SIZE = "10g"
}
cantaloupe_deployment_cpu_limit = "6"
cantaloupe_deployment_cpu_request = "0.5"
cantaloupe_deployment_memory_limit = "10Gi"
cantaloupe_deployment_memory_request = "1Gi"

#### Variables for Fester environment
fester_deployment_replicas = 2
fester_deployment_container_image_url = "uclalibrary/fester"
fester_deployment_container_image_version = "0.8.2"
fester_deployment_container_port = 8888
fester_deployment_container_env = {
  FESTER_HTTP_PORT = "8888"
  FESTER_S3_BUCKET = "stage-iiif-fester-source"
  FESTER_S3_REGION = "us-west-2"
  IIIF_BASE_URL = "https://stage-iiif.library.ucla.edu/iiif/2"
  FESTER_URL = "https://stage-iiif.library.ucla.edu"
}
fester_deployment_cpu_limit = "2"
fester_deployment_cpu_request = "0.25"
fester_deployment_memory_limit = "1Gi"
fester_deployment_memory_request = "128Mi"
