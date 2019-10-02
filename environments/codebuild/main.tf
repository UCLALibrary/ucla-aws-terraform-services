provider "aws" {
  region                  = "${var.region}"
}

resource "aws_iam_role" "codebuild_role" {
  name = "terraform-codebuild-shared-role"
  assume_role_policy = file("policies/codebuild-role-assume.json")
}

resource "aws_iam_role_policy" "codebuild_policy_ssm_codebuild" {
  role = "terraform-codebuild-shared-ssm-codebuild-policy"
  policy = file("policies/ssm-codebuild-policy.json")
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "${var.codebuild_project_name}"
  description   = "${var.codebuild_project_description}"
  build_timeout = "${var.codebuild_project_timeout_minutes}"
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

resource "aws_ssm_parameter" "bucketeer_s3_access_key" {
  name        = "AVTEST"
  description = "AVTEST"
  type        = "SecureString"
  value       = "AVTEST"
}

