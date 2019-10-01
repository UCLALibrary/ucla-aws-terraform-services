# UCLA Library Terraform Files - Services Team [![Build Status](https://travis-ci.com/UCLALibrary/ucla-aws-terraform-services.svg?branch=master)](https://travis-ci.com/UCLALibrary/ucla-aws-terraform-services)
This repository contains terraform configuration files that is used to provision the Services environment.

## How to use this Terraform Repository
### Prerequisites
* Terraform v0.12.9
* Access to UCLA Library [Terraform Enterprise](https://app.terraform.io/session)
  * TFE User Token
* Obtain local secrets file which is currently stored locally

### Steps to deploy
* `cd environments/test-iiif`
* `cp -rp backend.hcl.sample backend.hcl`
* `cp -rp yourlocalsecretsfile local.secrets`
  * Edit your local.secrets file as needed
* `bin/run`
* `terraform apply plan.out`

### Steps to destroy
* `cd environments/test-iiif`
* `bin/run destroy`
  * Answer `y`
