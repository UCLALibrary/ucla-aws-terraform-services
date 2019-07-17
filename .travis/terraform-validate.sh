#!/bin/bash

TERRAFORM_VERSION="0.12.4"
TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
### below vars is for my workstation...
#TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_darwin_amd64.zip"
#TRAVIS_BUILD_DIR="/Users/avuong/github-repos/ucla-aws-terraform-services"
TERRAFORM_BIN="${HOME}/terraform/bin"
TERRAFORM="${TERRAFORM_BIN}/terraform"

AWS_ENV=("prod")

mkdir -p ${TERRAFORM_BIN}
cd ${TERRAFORM_BIN}
wget ${TERRAFORM_URL}
unzip -o terraform*.zip
rm terraform*.zip

for ENV in "${AWS_ENV[@]}"
do
  echo "helloworld"
  cd "${TRAVIS_BUILD_DIR}/environments/${ENV}"
  ${TERRAFORM} init
  ${TERRAFORM} validate
done
