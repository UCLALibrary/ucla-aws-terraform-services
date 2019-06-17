terraform {
  backend "s3" {
    bucket = "softwaredev-services-terraform"
    key    = "test-cantaloupe/terraform-codebuild.tfstate"
    region = "us-west-2"
    shared_credentials_file = "~/.aws/credentials"
    profile = "services"
  }
}

provider "aws" {
  shared_credentials_file = "${var.cred_file}"
  profile                 = "${var.cred_profile}"
  region                  = "${var.region}"
}

resource "aws_iam_role" "codebuild_generic" {
  name = "codebuild_generic_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_generic" {
  role = "${aws_iam_role.codebuild_generic.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:Describe*",
        "ssm:Get*",
        "ssm:List*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "bucketeer" {
  name          = "bucketeer"
  description   = "Codebuild Project for docker bucketeer"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild_generic.arn}"
  badge_enabled = true

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/java:openjdk-11-1.7.0"
    type                        = "LINUX_CONTAINER"
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
  name        = "bucketeer.s3.access.key"
  description = "S3 Access key for bucketeer"
  type        = "SecureString"
  value       = "${var.bucketeer_s3_access_key}"
}

resource "aws_ssm_parameter" "bucketeer_s3_secret_key" {
  name        = "bucketeer.s3.secret.key"
  description = "S3 Secret key for bucketeer"
  type        = "SecureString"
  value       = "${var.bucketeer_s3_secret_key}"
}

resource "aws_ssm_parameter" "bucketeer_s3_bucket" {
  name        = "bucketeer.s3.bucket"
  description = "S3 bucket for bucketeer"
  type        = "String"
  value       = "${var.bucketeer_s3_bucket}"
}

resource "aws_ssm_parameter" "bucketeer_s3_region" {
  name        = "bucketeer.s3.region"
  description = "S3 bucket region for bucketeer"
  type        = "String"
  value       = "${var.bucketeer_s3_region}"
}

resource "aws_ssm_parameter" "services_docker_registry_username" {
  name        = "services.docker.registry.username"
  type        = "String"
  value       = "${var.services_docker_registry_username}"
}

resource "aws_ssm_parameter" "services_dockerhub_password" {
  name        = "services.dockerhub.password"
  type        = "SecureString"
  value       = "${var.services_dockerhub_password}"
}

resource "aws_ssm_parameter" "services_dockerhub_username" {
  name        = "services.dockerhub.username"
  type        = "SecureString"
  value       = "${var.services_dockerhub_username}"
}