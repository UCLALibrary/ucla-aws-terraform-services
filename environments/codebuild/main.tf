provider "aws" {
  region                  = "${var.region}"
}

resource "aws_iam_role" "codebuild_role" {
  name = "terraform-codebuild-shared-role"
  assume_role_policy = file("policies/codebuild-role-assume.json")
}

resource "aws_iam_role_policy" "codebuild_policy_ssm_codebuild" {
  role = "${aws_iam_role.codebuild_role.name}"
  policy = file("policies/ssm-codebuild-policy.json")
}

resource "aws_codebuild_project" "docker-cantaloupe" {
  name          = "docker-cantaloupe"
  description   = "CodeBuild job for building docker-cantaloupe images"
  build_timeout = "20"
  service_role  = "${aws_iam_role.codebuild_role.arn}"
  badge_enabled = true

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "${var.codebuild_project_image}"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/UCLALibrary/docker-jp2-bucketeer.git"
    buildspec       = ".buildspec.yml"
  }

  secondary_sources {
    type               = "GITHUB"
    source_identifier = "KAKADU"
    location           = "https://github.com/UCLALibrary/kakadu.git"
  }
}

module "ssm_parameters" {
  source   = "git::https://github.com/UCLALibrary/terraform-ssm-parameters.git?ref=1.0.0"
  ssm_list = "${var.ssm_parameters_list}"
}

