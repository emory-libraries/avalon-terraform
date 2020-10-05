variable "app_name" {
  default = "avalon"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
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

variable "bastion_instance_type" {
  default = "t2.micro"
}

variable "base_policy_arns" {
  type = list(string)
  default = []
  description = "Additional base policy arns that will be attached to every role that the template creates."
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

variable "ssh_cidr_block" {
  type = string
}

variable "vpc_cidr_block" {
  default = "10.1.0.0/16"
}

variable "vpc_public_subnets" {
  type    = list(string)
  default = ["10.1.2.0/24", "10.1.4.0/24", "10.1.6.0/24"]
}

variable "vpc_private_subnets" {
  type    = list(string)
  default = ["10.1.1.0/24", "10.1.3.0/24", "10.1.5.0/24"]
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
  default = ["Private Subnet 1", "Private Subnet 2"]
}

variable "private_key_file" {
  type = string
}

variable "certificate_body_file" {
  type = string
}