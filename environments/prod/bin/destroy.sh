#!/bin/bash

BACKEND_FILE="backend.hcl"
TERRAFORM="/opt/terraform/bin/terraform"
PLAN_FILE="current.plan"
LOCAL_SECRETS="local.secrets"
WORKSPACE="prod"

if [[ ! -f ${BACKEND_FILE} ]];
then
  echo "${BACKEND_FILE} not found"
  exit
fi


if [[ -z $(${TERRAFORM} workspace list | grep -i ${WORKSPACE}) ]];
then
  ${TERRAFORM} workspace new ${WORKSPACE}
else
  ${TERRAFORM} workspace select ${WORKSPACE}
fi

echo "Working in workspace: $(${TERRAFORM} workspace show)"

${TERRAFORM} init \
  -backend-config="${BACKEND_FILE}"

if [[ -f "${LOCAL_SECRETS}" ]];
then
  ${TERRAFORM} destroy -var-file="${WORKSPACE}.tfvars" -var-file="${LOCAL_SECRETS}" 
else
  ${TERRAFORM} destroy ${PLAN_FILE} -var-file="${WORKSPACE}.tfvars" 
fi
