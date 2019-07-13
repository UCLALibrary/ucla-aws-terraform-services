#!/bin/bash
terraform init
terraform workspace select prod
terraform plan -var-file="prod.tfvars" -var-file="local.secrets" -out current.plan
