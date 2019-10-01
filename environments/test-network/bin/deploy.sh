#!/bin/bash

BACKEND_FILE="backend.hcl"
PLAN_FILE="current.plan"
LOCAL_SECRETS="local.secrets"
WORKSPACE="networking"

if [[ ! -f ${BACKEND_FILE} ]];
then
  echo "${BACKEND_FILE} not found"
  exit
fi

terraform init \
  -backend-config="${BACKEND_FILE}"

if [[ -z $(terraform workspace list | grep -i ${WORKSPACE}) ]];
then
  terraform workspace new ${WORKSPACE}
else
  terraform workspace select ${WORKSPACE}
fi

echo "Working in workspace: $(terraform workspace show)"

if [[ -f "${LOCAL_SECRETS}" ]];
then
  terraform plan -out ${PLAN_FILE} -var-file="${LOCAL_SECRETS}" 
else
  terraform plan -out ${PLAN_FILE}
fi
