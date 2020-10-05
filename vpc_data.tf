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

data "aws_subnet" "selected" {
    for_each = data.aws_subnet_ids.selected.ids
    id = each.value
}