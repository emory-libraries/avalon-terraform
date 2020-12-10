# Emory Libraries adaption of Avalon-Terraform

## Goals

The goal of this fork is to deploy Avalon in a restricted aws@emory account. The original version of this presumes full access to a standard AWS account. AWS@emory accounts are restricted and many services are not allowed or only partially available.

## Architecture diagram

![](diagram.jpg)

## Getting started

## Prerequisites

1. Download and install [Terraform 0.12+](https://www.terraform.io/downloads.html). The scripts have been upgraded to HCL 2 and therefore incompatible with earlier versions of Terraform.
1. Clone this repo or use the git-subtree method. Note that you must remove the .gitignore of *.tfvars in order to save variable files to github, it's recommend to use a private repo and git-crypt to manage secrets.
1. Create or import an [EC2 key-pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) for your region.
2. Create a VPC and designate subnets to be used with this project. These subnets must be given Name tags.
3. Create an IAM user that Fedora will use to sign its S3 requests.
4. Create an S3 bucket to hold the terraform state, this is useful when
    executing terraform on multiple machines (or working as a team) because it allows state to remain in sync.
    This will also require the creation of a dynamodb table to manage the statefile lock.
5. Fill out provider and state information in [main.tf](main.tf)
    
    ```hcl
    provider "aws" {
      region = "us-east-1"
      profile = "aws-profile-name-here"
    }

    terraform {
      backend "s3" {
      bucket = "created-bucket-here"
      region = "us-east-1"
      key    = "terraform.tfstate"
      profile = "aws-profile-name-here"
      encrypt = true
      dynamodb_table = "dynamo-db-table-here"
      }
    }
    ```

6. Execute `terraform init`, to initialize the backend.
7. Create a new workspace, it is not recommended to use the default workspace, for example `terraform workspace new prod` will create a prod workspace.
   If multiple workspaces/environments are desired, create a .tfvars file for each workspace, for example prod.tfvars. Use this file with the --vars-file flag
8. Fill out relevant variables, check the variables section to see which are required.

## Variables

### Variables are separated into two catagories: AWS Variables and Avalon Application Variables

The AWS variables are found in this [table](readme/aws_var.md)
The Avalon Application variables are listed [here](readme/avalon_variables.md)

## Bringing up the stack

To see the changes Terraform will make:

    terraform plan --var-file=[workspace].tfvars

To actually make those changes:

    terraform apply --var-file=[workspace].tfvars


### Authentication

Turnkey comes bundled with [Persona](https://github.com/samvera-labs/samvera-persona) by default but can be configured to work with other authentication strategies by using the appropriate omniauth gems. Refer to [this doc](https://wiki.dlib.indiana.edu/display/VarVideo/Manual+Installation+Instructions#ManualInstallationInstructions-AuthenticationStrategy) for integration instruction.

Emory Avalon is integrated with Omniauth SAML and Omniauth LTI, many of the Avalon Application variables related to these integrations.

## Maintenance

## Update the stack

You can proceed with `terraform plan --var-file=[workspace].tfvars` and `terraform apply --var-file=[workspace].tfvars` as often as you want to see and apply changes to the
stack. Changes you make to the `*.tf` files  will automatically be reflected in the resources under Terraform's
control.

## Destroy the stack

Special care must be taken if you want to retain all data when destroying the stack. If that wasn't a concern, you can simply run
    
    terraform destroy --var-file=[workspace].tfvars

## Update the containers

Since Avalon, Fedora, Solr and Nginx are running inside Docker containers managed by docker-compose, you can SSH to the EC2 box and run docker-compose commands as usual.

    docker-compose pull
    docker-compose up -d

## Performance & Cost

The EC2 instances are sized to minimize cost and allow occasional bursts (mostly by using `t3`). However if your system is constantly utilizing 30%+ CPU, it might be cheaper & more performant to switch to larger `t2` or `m5` instances.

Cost can be further reduced by using [reserved instances](https://aws.amazon.com/ec2/pricing/reserved-instances/pricing/) - commiting to buy EC2 for months or years.

Out of the box, the system can service up to 100 concurrent streaming users without serious performance degradation. More performance can be achieved by scaling up using a larger EC2 instance.

## Upstream Changes

Since this repository is a fork, work may happen in the upstream repository that we want to incorporate here.
In order to do this, the `master` branch of this repository will track the `master` branch from avalonmediasystem, which can be set up as follows:

1. Add avalonmediasystem/avalon-terraform as a new remote (called "upstream" here): ```git remote add upstream git@github.com:avalonmediasystem/avalon-terraform.git```
2. Pull in info from that remote: `git fetch upstream`
3. Ensure you are on our master branch: `git checkout master`
4. Track the `master` branch from avalonmediasystem as the upstream branch of our `master` branch: `git branch -u upstream/master`

Now when changes are made in avalonmediasystem/avalon-terraform's `master`, we can pull them in and push them to GitHub's `master` with three steps:

1. Ensure you are on our master branch: `git checkout master`
2. Pull in changes from avalonmediasystem: `git pull`
3. Push changes to GitHub (assuming your GitHub remote is called "origin", as it is by default): `git push origin`

It is important that the `master` branch only recieves updates from upstream, so that it can continue to fast-forward those changes in our repository.
