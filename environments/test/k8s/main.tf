terraform {
  required_version = "~> 0.12.20"
  backend "remote" {}
}

provider "kubernetes" {
  load_config_file = "true"
}


resource "kubernetes_deployment" "example" {
  metadata {
    name = "AVTEST"
    namespace = "test-iiif"
      app = "AVTEST"
    }
  }

  template {
    metadata {
      labels = {
        test = "MyExampleApp"
      }
    }

    spec {
      container {
        image = "uclalibrary/cantaloupe-ucla:4.1.4"
        name  = "AVTEST"
        image_pull_secrets = "Always"
        port = 8182
      }
    }
  }
}
