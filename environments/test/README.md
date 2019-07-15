# Production Environment
* iiif.library.ucla.edu

## Instructions
This environment heavily utilizes modules to build AWS environments via Terraform. The only changes you should have to make are the following:

* prod.tfvars
* local.secrets(unlikely for you to have one, you'll have to create your own)

After editing the vars file, you can run the bootstrap script

```
./bootstrap.sh
```

This will generate a plan file for you to apply

## Modules utilized under ../../modules
* cantaloupe
* alb
* vpc
