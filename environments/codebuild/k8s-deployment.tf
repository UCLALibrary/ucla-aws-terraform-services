resource "aws_codebuild_project" "k8s_deployment" {
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

resource "aws_ssm_parameter" "k8s_parameters" {
  for_each = local.iiif_k8s_ssm_parameters_merged

  name        = each.key
  description = each.value[0]
  type        = each.value[1]
  value       = each.value[2]
}
