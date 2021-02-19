variable "app_name" {
  default = "avalon"
}

variable "aws_profile" {
  default = "default"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "avalon_admin" {
  default = "admin@example.com"
}

variable "avalon_repo" {
  default = "https://github.com/emory-libraries/avalon"
  description = "Determines what github repo AWS CodeBuild builds from"
}

variable "avalon_branch" {
  default = "main"
  description = "Controls which github branch of the avalon repo is used by AWS CodeBuild"
}

variable "application_fqdn" {
  type = string
  description = <<EOF
    The fully qualified production domain name. This is name is used only by the application load balancer, not route53.
    Note that the template will also create another domain name for streaming that is streaming.{application_fqdn}.
    EOF
}
variable "application_fqdn_workspace_insertion_index" {
  type = number
  default = 0
  description = <<EOF
    The application fqdn is split into a list at each '.', this variable is the index (first object is 0) where the workspace will be appended.
    For example if the application fqdn is 'avr.emory.edu', this variable is set to 0, and the workspace is test, the output will be avr-test.emory.edu.
    If the workspace is 'prod' or 'prod2' then nothing is appended to the fqdn and the address on the alb would be 'avr.emory.edu'. 
    EOF
}
variable "bastion_instance_type" {
  default = "t2.micro"
}

variable "base_policy_arns" {
  type = list(string)
  default = []
  description = "Additional base policy arns that will be attached to every role the template creates."
}

variable "compose_docker_branch" {
  default = "aws_min"
  description = "Controls which branch of avalon-docker the compose ec2 will download and unzip during setup"
}

variable "compose_instance_type" {
  default = "t3.large"
  description = "The instance size of the ec2 that runs the avalon docker containers"
}

variable "compose_volume_size" {
  type = number
  default = 150
  description = "The root volume size of the ec2 that runs the avalon docker containers"
}

variable "db_avalon_username" {
  default = "dbavalon"
}

variable "db_fcrepo_username" {
  default = "dbfcrepo"
}

variable "ec2_keyname" {
  type = string
  description = "The name of the key in AWS that the ec2 will use for SSH login"
}

variable "ec2_private_keyfile" {
  type = string
  description = "Path to the ec2 private key file, this will allow you to SSH inside the EC2 and run commands The key should have '0600' file permission."
}

variable "email_comments" {
  type = string
}

variable "email_notification" {
  type = string
}

variable "email_support" {
  type = string
}

variable "fcrepo_binary_bucket_yaml_file" {
  type = string
  description = "Path to a YAML file containing the access and secret key for the fcrepo binary. An example exists [here](fcrepo_binary_bucket_example.md)."
}

variable "hosted_zone_name" {
  type = string
}

variable "postgres_version" {
  default = "10.6"
}

variable "sms_notification" {
  type = string
}

variable "stack_name" {
  default = "stack"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ssh_cidr_blocks" {
  type = list(string)
  default = ["0.0.0.0/0"]
  description = "List of cidr blocks the compose ec2 will allow SSH access from, defaults to the entire internet" 
}

locals {
  namespace         = "${var.stack_name}-${terraform.workspace}"
  public_zone_name  = "${terraform.workspace}.${var.hosted_zone_name}"
  private_zone_name = "vpc.${terraform.workspace}.${var.hosted_zone_name}"

  common_tags = merge(
    var.tags,
    {
      "Terraform"   = "true"
      "Environment" = local.namespace
      "Project"     = "Infrastructure"
    },
  )
}

variable "vpc_id" {
  type = string
  description = "VPC that will be used by terraform, this VPC is called via data only, terraform will not attempt to manage the existence of the VPC"
}

variable "subnet_tags" {
  type = list(string)
  description = "List of Subnet Name tags, these subnets should exist in the provided VPC and there need to be a minimum of two in different availability zones."
}

variable "private_key_file" {
  type = string
  description = "Path to a the PEM-formatted private key for the avalon website. This will be loaded into AWS Certificate Manager(ACM) and used by the Application Load Balancer(ALB). Max supported RSA Key size is 2048"
}

variable "certificate_body_file" {
  type = string
  description = "Path the PEM-formatted signed certificate for the avalon website, this will be loaded into ACM and used by the ALB."
}

variable "certificate_chain_file" {
  type = string
  description = "Path to the PEM-formatted interm or chain certificate, some regions may require the chain cert be in 'reverse' format."
}
