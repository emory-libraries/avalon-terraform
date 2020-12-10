# Emory Libraries adaption of Avalon-Terraform

# Goals

The goal of this fork is to deploy Avalon in a restricted aws@emory account. The original version of this presumes full access to a standard AWS account. AWS@emory accounts are restricted and many services are not allowed or only partially available.

# Architecture diagram
![](diagram.jpg)

# Getting started

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

### There are many variables with the project, the variables are separated into two files: one for AWS and EC2 related settings and another for the Avalon Rails Application

### AWS Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_name | n/a | `string` | `"avalon"` | no |
| application\_fqdn | The fully qualified production domain name. This is name is used only by the application load balancer, not route53.<br>    Note that the template will also create another domain name for streaming that is streaming.{application\_fqdn}. | `string` | n/a | yes |
| application\_fqdn\_workspace\_insertion\_index | The application fqdn is split into a list at each '.', this variable is the index (first object is 0) where the workspace will be appended.<br>    For example if the application fqdn is 'avr.emory.edu', this variable is set to 0, and the workspace is test, the output will be avr-test.emory.edu.<br>    If the workspace is 'prod' then nothing is appended to the fqdn and the address on the alb would be 'avr.emory.edu'. | `number` | `0` | no |
| avalon\_admin | n/a | `string` | `"admin@example.com"` | no |
| avalon\_branch | Controls which github branch of the avalon repo is used by AWS CodeBuild | `string` | `"main"` | no |
| avalon\_repo | Determines what github repo AWS CodeBuild builds from | `string` | `"https://github.com/emory-libraries/avalon"` | no |
| aws\_profile | n/a | `string` | `"default"` | no |
| aws\_region | n/a | `string` | `"us-east-1"` | no |
| base\_policy\_arns | Additional base policy arns that will be attached to every role the template creates. | `list(string)` | `[]` | no |
| bastion\_instance\_type | n/a | `string` | `"t2.micro"` | no |
| certificate\_body\_file | Path the PEM-formatted signed certificate for the avalon website, this will be loaded into ACM and used by the ALB. | `string` | n/a | yes |
| certificate\_chain\_file | Path to the PEM-formatted interm or chain certificate, some regions may require the chain cert be in 'reverse' format. | `string` | n/a | yes |
| compose\_docker\_branch | Controls which branch of avalon-docker the compose ec2 will download and unzip during setup | `string` | `"aws_min"` | no |
| compose\_instance\_type | The instance size of the ec2 that runs the avalon docker containers | `string` | `"t3.large"` | no |
| compose\_volume\_size | The root volume size of the ec2 that runs the avalon docker containers | `number` | `150` | no |
| db\_avalon\_username | n/a | `string` | `"dbavalon"` | no |
| db\_fcrepo\_username | n/a | `string` | `"dbfcrepo"` | no |
| ec2\_keyname | The name of the key in AWS that the ec2 will use for SSH login | `string` | n/a | yes |
| ec2\_private\_keyfile | Path to the ec2 private key file, this will allow you to SSH inside the EC2 and run commands The key should have '0600' file permission. | `string` | n/a | yes |
| email\_comments | n/a | `string` | n/a | yes |
| email\_notification | n/a | `string` | n/a | yes |
| email\_support | n/a | `string` | n/a | yes |
| fcrepo\_binary\_bucket\_access\_key | n/a | `string` | n/a | yes |
| fcrepo\_binary\_bucket\_secret\_key | n/a | `string` | n/a | yes |
| fcrepo\_binary\_bucket\_username | n/a | `string` | n/a | yes |
| hosted\_zone\_name | n/a | `string` | n/a | yes |
| postgres\_version | n/a | `string` | `"10.6"` | no |
| private\_key\_file | Path to a the PEM-formatted private key for the avalon website. This will be loaded into AWS Certificate Manager(ACM) and used by the Application Load Balancer(ALB). Max supported RSA Key size is 2048 | `string` | n/a | yes |
| sms\_notification | n/a | `string` | n/a | yes |
| ssh\_cidr\_blocks | List of cidr blocks the compose ec2 will allow SSH access from, defaults to the entire internet | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| stack\_name | n/a | `string` | `"stack"` | no |
| subnet\_tags | List of Subnet Name tags, these subnets should exist in the provided VPC and there need to be a minimum of two in different availability zones. | `list(string)` | n/a | yes |
| tags | n/a | `map(string)` | `{}` | no |
| vpc\_id | VPC that will be used by terraform, this VPC is called via data only, terraform will not attempt to manage the existence of the VPC | `string` | n/a | yes |

### Avalon App Variables


## Bringing up the stack

To see the changes Terraform will make:

    terraform plan

To actually make those changes:

    terraform apply

Be patient, the script attempts to register SSL certificates for your domains and AWS cert validation process can take from 5 to 30 minutes.

## Extra settings

### Email

In order for Avalon to send mails using AWS, you need to add these variables to the `terraform.tfvars` file and make sure these email addresses are [verified in Simple Email Service](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-email-addresses.html):

    email_comments      = "comments@mydomain.org"
    email_notification  = "notification@mydomain.org"
    email_support       = "support@mydomain.org"

### Authentication

Turnkey comes bundled with [Persona](https://github.com/samvera-labs/samvera-persona) by default but can be configured to work with other authentication strategies by using the appropriate omniauth gems. Refer to [this doc](https://wiki.dlib.indiana.edu/display/VarVideo/Manual+Installation+Instructions#ManualInstallationInstructions-AuthenticationStrategy) for integration instruction.

# Maintenance

## Update the stack
You can proceed with `terraform plan` and `terraform apply` as often as you want to see and apply changes to the
stack. Changes you make to the `*.tf` files  will automatically be reflected in the resources under Terraform's
control.

## Destroy the stack
Special care must be taken if you want to retain all data when destroying the stack. If that wasn't a concern, you can simply run
    
    terraform destroy

## Update the containers
Since Avalon, Fedora, Solr and Nginx are running inside Docker containers managed by docker-compose, you can SSH to the EC2 box and run docker-compose commands as usual.

    docker-compose pull
    docker-compose up -d

## Performance & Cost
The EC2 instances are sized to minimize cost and allow occasional bursts (mostly by using `t3`). However if your system is constantly utilizing 30%+ CPU, it might be cheaper & more performant to switch to larger `t2` or `m5` instances.

Cost can be further reduced by using [reserved instances](https://aws.amazon.com/ec2/pricing/reserved-instances/pricing/) - commiting to buy EC2 for months or years.

Out of the box, the system can service up to 100 concurrent streaming users without serious performance degradation. More performance can be achieved by scaling up using a larger EC2 instance.

# Upstream Changes

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_ldap\_groups | Comma separated list of LDAP Groups, a user who is a member on any list will login as an administrator. | `list(string)` | `[]` | no |
| assertion\_cs\_url | The URL at which the SAML assertion should be received. If not provided, defaults to the OmniAuth callback URL | `string` | `""` | no |
| assertion\_logout\_url | n/a | `string` | `""` | no |
| csp\_frame\_ancestors | Sets allowed urls for the Content Security Policy header | `string` | `""` | no |
| fedora\_ssl | Forces the fedora database connection to use ssl. | `bool` | `false` | no |
| idp\_cert\_file | n/a | `string` | `"Path to IDP's cert, cert should be in PEM format."` | no |
| idp\_slo\_target\_url | The URL to which the single logout request and response should be sent. This would be on the identity provider. | `string` | `""` | no |
| idp\_sso\_target\_url | The URL to which the authentication request should be sent. This would be on the identity provider. | `string` | `""` | no |
| issuer | The name of your application. Some identity providers might need this to establish the identity of the service provider requesting the login. Also know as EntityID | `string` | `""` | no |
| lti\_auth\_key | This LTI value is the 'username', it identifies the service to Canvas | `string` | `""` | no |
| lti\_auth\_secret | This LTI value is the 'password' | `string` | `""` | no |
| secret\_key\_base | n/a | `string` | `"a882b3f2f6144681b2fc0eb23fbdc8904c806fae882a3b6ada84ae83a4d967a9200e1ea27ee6c3049b1ca8bae040d844f04457d0f58c125813d3978a36898675"` | no |
| sp\_cert\_file | Path to the service provider's cert, in standard PEM format. | `string` | `""` | no |
| sp\_key\_file | Path to the service provider's private key, in standard PEM format. | `string` | `""` | no |
