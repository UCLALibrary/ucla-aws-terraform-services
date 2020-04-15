image_pull_secrets = "services-dockerhub-creds"

#### Variables for Cantaloupe environment
cantaloupe_deployment_replicas = 2
cantaloupe_deployment_namespace = "test-iiif"
cantaloupe_deployment_name = "cantaloupe"
cantaloupe_deployment_labels = {
  app = "cantaloupe"
}
cantaloupe_deployment_container_image_url = "uclalibrary/cantaloupe-ucla"
cantaloupe_deployment_container_image_version = "4.1.4"
cantaloupe_deployment_container_name = "cantaloupe"
cantaloupe_deployment_container_image_pull_policy = "Always"
cantaloupe_deployment_container_port = 8182


#### Variables for Fester environment
fester_deployment_replicas = 2
fester_deployment_namespace = "test-iiif"
fester_deployment_name = "fester"
fester_deployment_labels = {
  app = "fester"
}
fester_deployment_container_image_url = "uclalibrary/fester"
fester_deployment_container_image_version = "latest"
fester_deployment_container_name = "fester"
fester_deployment_container_image_pull_policy = "Always"
fester_deployment_container_port = 8888

cantaloupe_deployment_container_env = {
  CANTALOUPE_ENDPOINT_ADMIN_ENABLED = "true"
  CANTALOUPE_CACHE_SERVER_DERIVATIVE_ENABLED = "true"
  CANTALOUPE_CACHE_SERVER_DERIVATIVE = "S3Cache"
  CANTALOUPE_CACHE_SERVER_DERIVATIVE_TTL_SECONDS = "0"
  CANTALOUPE_CACHE_SERVER_PURGE_MISSING = "true"
  CANTALOUPE_PROCESSOR_SELECTION_STRATEGY = "ManualSelectionStrategy"
  CANTALOUPE_MANUAL_PROCESSOR_JP2 = "KakaduNativeProcessor"
  CANTALOUPE_S3CACHE_ENDPOINT = "s3.us-west-2.amazonaws.com"
  CANTALOUPE_S3CACHE_BUCKET_NAME = "test-iiif-cantaloupe-cache"
  CANTALOUPE_S3SOURCE_BUCKET_NAME = "test-iiif-cantaloupe-source"
  CANTALOUPE_S3SOURCE_ENDPOINT = "s3.us-west-2.amazonaws.com"
  CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX = ".jpx"
  CANTALOUPE_SOURCE_STATIC = "S3Source"
  JAVA_HEAP_SIZE = "4g"
}

fester_deployment_container_env = {
  FESTER_HTTP_PORT = "8888"
  FESTER_S3_BUCKET = "test-iiif-fester-source"
  FESTER_S3_REGION = "us-west-2"
  IIIF_BASE_URL = "https://test-iiif.library.ucla.edu/iiif/2"
}
