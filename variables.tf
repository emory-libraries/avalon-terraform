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
}

variable "avalon_branch" {
  default = "master"
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
    If the workspace is 'prod' then nothing is appended to the fqdn and the address on the alb would be 'avr.emory.edu'. 
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

variable "compose_instance_type" {
  default = "t3.large"
}

variable "db_avalon_username" {
  default = "dbavalon"
}

variable "db_fcrepo_username" {
  default = "dbfcrepo"
}

variable "ec2_keyname" {
  type = string
}

variable "ec2_private_keyfile" {
  type = string
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

variable "fcrepo_binary_bucket_username" {
  type = string
}

variable "fcrepo_binary_bucket_access_key" {
  type = string
}

variable "fcrepo_binary_bucket_secret_key" {
  type = string
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

variable "stack_key" {
  type    = string
  default = "stack.tfstate"
}

variable "stack_region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ssh_cidr_blocks" {
  type = list(string)
  default = ["0.0.0.0/0"]
  description = "List of cidr blocks the compose ec2 will allow SSH access from" 
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
}

variable "subnet_tags" {
  type = list(string)
}

variable "private_key_file" {
  type = string
}

variable "certificate_body_file" {
  type = string
}

variable "certificate_chain_file" {
  type = string
}
