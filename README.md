Turnkey solution for Avalon on AWS, using Terraform

# Goals

The goal of this solution is to provide a simple, cost-effective way to put Avalon on the cloud, while remaining resilient, performant and easy to manage. It aims to serve collections with low to medium traffic.

# Architecture diagram
![](diagram.jpg)

# Getting started
## Prerequisites

1. Download and install [Terraform 0.12+](https://www.terraform.io/downloads.html). The scripts have been upgraded to HCL 2 and therefore incompatible with earlier versions of Terraform.
1. Clone this repo
1. Create or import an [EC2 key-pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) for your region.
1. Create an S3 bucket to hold the terraform state, this is useful when
    executing terraform on multiple machines (or working as a team) because it allows state to remain in sync. 
1. Copy `dev.tfbackend.example` to `dev.tfbackend` and fill in the previously created bucket name.

    ```
    bucket = "my-terraform-state"
    key    = "state.tfstate"
    region = "us-east-1"
    ````
1. Create an IAM user that Fedora will use to sign its S3 requests.
1. Create a [public hosted zone in Route53](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html); Terraform will automatically manage DNS entries in this zone. A registered domain name is needed to pair with the Route53 hosted zone. You can [use Route53 to register a new domain](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html) or [use Route53 to manage an existing domain](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/MigratingDNS.html).
1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in the relevant information:
    ```
    hosted_zone_name    = "mydomain.org"
    ec2_keyname         = "my-ec2-key"
    ec2_private_keyfile = "/local/path/my-ec2-key.pem"
    stack_name          = "mystack"
    sms_notification    = "+18125550123"
    fcrepo_binary_bucket_username   = "iam_user"
    fcrepo_binary_bucket_access_key = "***********"
    fcrepo_binary_bucket_secret_key = "***********"
    tags {
      Creator    = "me"
      AnotherTag = "Whatever value I want!"
    }
    ```
    * Note: You can have more than one variable file and pass the name on the command line to manage more than one stack.
    * Note2: The terraform workspace is considered the environment
2. Execute `terraform init  -reconfigure -backend-config=dev.tfbackend`.

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
