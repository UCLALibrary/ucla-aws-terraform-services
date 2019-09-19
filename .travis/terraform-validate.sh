#!/bin/bash

TERRAFORM_VERSION="0.12.6"
TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
TERRAFORM_BIN="${HOME}/terraform/bin"
TERRAFORM="${TERRAFORM_BIN}/terraform"

AWS_ENV=("test-iiif", "prod-iiif", "prod-network", "test-network", "prod-sinai")

mkdir -p ${TERRAFORM_BIN}
cd ${TERRAFORM_BIN}
wget ${TERRAFORM_URL}
unzip -o terraform*.zip
rm terraform*.zip

for ENV in "${AWS_ENV[@]}"
do
  cd "${TRAVIS_BUILD_DIR}/environments/${ENV}"
  ${TERRAFORM} init -backend=false
  ${TERRAFORM} validate
done

