#!/bin/bash
LOCAL_SECRET_FILE="local.secrets"
VARS_FILE="prod.tfvars"
PLAN_FILE="current.plan"
WORKSPACE="prod"

terraform init
terraform workspace select $WORKSPACE

if [[ -f "$LOCAL_SECRET_FILE" ]]; then
  terraform plan -var-file=$VARS_FILE -var-file=$LOCAL_SECRET_FILE -out $PLAN_FILE
else
  terraform plan -var-file=$VARS_FILE -out $PLAN_FILE
fi