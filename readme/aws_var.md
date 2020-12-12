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
