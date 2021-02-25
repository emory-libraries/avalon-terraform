data "aws_subnet_ids" "selected" {
    vpc_id  = var.vpc_id
    filter {
        name    = "tag:Name"
        values  = var.subnet_tags
    }
}

data "aws_vpc" "selected" {
    id = var.vpc_id
}

resource "random_shuffle" "random_subnet" {
    input = data.aws_subnet_ids.selected.ids
    result_count = 1 
}

data "aws_subnet" "random" {
    id  = random_shuffle.random_subnet.result.0
}

data "aws_subnet" "selected" {
    for_each = data.aws_subnet_ids.selected.ids
    id = each.value
}

locals {
    aws_subnet_arns = [for s in data.aws_subnet.selected : s.arn ]
    application_fqdn_list = split(".", var.application_fqdn)
    appended_fqdn_list = terraform.workspace == "prod" || terraform.workspace == "prod2" ? local.application_fqdn_list : formatlist("%s-${terraform.workspace}", local.application_fqdn_list)
    appended_fqdn = replace(var.application_fqdn, local.application_fqdn_list[var.application_fqdn_workspace_insertion_index], local.appended_fqdn_list[var.application_fqdn_workspace_insertion_index])
    streaming_appended_fqdn = replace(local.appended_fqdn, local.appended_fqdn_list[var.application_fqdn_workspace_insertion_index], "streaming.${local.appended_fqdn_list[var.application_fqdn_workspace_insertion_index]}")
    aws_secret_yaml_file = file(var.fcrepo_binary_bucket_yaml_file)
    fedora_aws_access_key = yamldecode(local.aws_secret_yaml_file)[terraform.workspace]["aws_access_key"]
    fedora_aws_secret_key = yamldecode(local.aws_secret_yaml_file)[terraform.workspace]["aws_secret_key"]
}
