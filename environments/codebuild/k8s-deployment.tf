resource "aws_codebuild_project" "k8s-deployment" {
  name          = "iiif-k8s-deployment"
  description   = "CodeBuild job for orchestrating Kubernetes deployments on EKS"
  build_timeout = "5"
  service_role  = data.terraform_remote_state.iam.outputs.eks_shared_codebuild_robot_arn
  badge_enabled = false

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.12.20"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/UCLALibrary/ucla-aws-terraform-services.git"
    buildspec       = ".buildspec.yaml"
  }
}

#module "ssm_parameters" {
#  source  = "app.terraform.io/UCLALibrary/ssmparameters/aws"
#  version = "1.0.0"
#  ssm_list = "${local.ssm_parameters_merged}"
#}
