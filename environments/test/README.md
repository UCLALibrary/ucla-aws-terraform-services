## Test EKS Environment
This environment currently utilizes the following AWS resources:
* AWS VPC
* AWS NAT Gateway
* AWS Security Groups
* AWS IAM Roles/Policies
* AWS EKS
* AWS EKS NodeGroups
* AWS EC2
* AWS S3
* AWS CloudWatch

### Prerequisites
* Terraform 0.12.20 >=
* Access to UCLA Library [Terraform Cloud](https://app.terraform.io/session)
  * TFE User Token
* Obtain `secrets.tfvars` from protected vault

### Orchestration of Terraform deployment
If this is the first time launching this environment, you'll have to deploy the various components in the following order:
* eks-networking (Networking)
* eks-iam (IAM roles and policies)
* eks (EKS service)

### Steps to deploy/update
The orchestration of this environment is heavily dependent on using helper scripts found in the bin directory. Here's how to create/update a new environment:

* Make sure you're in the root of the test environment
  * `cd environments/test`
* `bin/gen-backend-config eks-network`
  * You'll need to supply an Organization name and Token from Terraform Cloud
* `bin/run eks-network pre-setup-vpc`
  * This creates dependency resources before the VPC can be fully deployed
* `bin/run eks-network apply`
  * This will deploy the targeted dependency resources needed before proceeding to the next steps
* `bin/run eks-network`
  * This will generate a plan to fully deploy the VPC needed for the EKS environment
* `bin/run eks-network apply`
  * Run the plan to create the VPC environment
* `bin/gen-backend-config eks-iam`
  * You'll need to supply an Organization name and Token from Terraform Cloud
* `bin/run eks-iam`
  * This will generate a plan to create IAM roles and policies needed to deploy EKS and NodeGroups
* `bin/run eks-iam apply`
  * Run the plan to deploy the EKS IAM resources
* `bin/gen-backend-config eks
  * You'll need to supply an Organization name and Token from Terraform Cloud
* `bin/run eks`
  * This will generate a plan to create a general purpose Nodegroup and an EKS cluster
* `bin/run eks apply`
  * Run the plan to deploy EKS

### Steps to destroy an environment
To destroy an environment, you'll need to use the destroy flag:

* `cd environments/test`
* `bin/run [env] destroy`
  * `bin/run eks destroy`
  * `bin/run eks-iam destroy`
  * `bin/run eks-network destroy`

