# Test Environment
* test-iiif.library.ucla.edu

## Instructions
This environment heavily utilizes modules to build AWS environments via Terraform. The only changes you should have to make are the following:

* local.secrets (unlikely for you to have one, you'll have to create your own. feel free to copy the sample file)

After editing the vars file, you can run the bootstrap script

```
cd environments/test
bin/deploy.sh
terraform apply current.plan # confirm that you're OK with the plan generated first!
```

This will generate a plan file for you to apply

## Modules utilized under ../../modules
* cantaloupe
* alb
* vpc
* manifeststore
* lambda
* s3
