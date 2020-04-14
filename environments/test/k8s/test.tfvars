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
