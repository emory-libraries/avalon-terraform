# Variable Passthroughs

output "workspace" {
  value = terraform.workspace
}

output "aws_region" {
  value = var.aws_region
}

output "alb_dns_name" {
  value = aws_alb.alb.dns_name
}

output "ec2_keyname" {
  value = var.ec2_keyname
}

output "ec2_private_keyfile" {
  value = var.ec2_private_keyfile
}

output "ec2_private_ip" {
  value = aws_instance.compose.private_ip
}

output "hosted_zone_name" {
  value = var.hosted_zone_name
}

output "stack_name" {
  value = var.stack_name
}

output "tags" {
  value = var.tags
}

output "vpc_cidr_block" {
  value = data.aws_vpc.selected.cidr_block
}

output "cache_address" {
  value = aws_route53_record.redis.name
}

output "cache_port" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].port
}


output "db_avalon_address" {
  value = module.db_avalon.this_db_instance_address
}

output "db_avalon_port" {
  value = module.db_avalon.this_db_instance_port
}

output "db_avalon_username" {
  value = module.db_avalon.this_db_instance_username
}

output "db_avalon_password" {
  value = module.db_avalon.this_db_instance_password
}

output "db_fcrepo_address" {
  value = module.db_fcrepo.this_db_instance_address
}

output "db_fcrepo_port" {
  value = module.db_fcrepo.this_db_instance_port
}

output "db_fcrepo_username" {
  value = module.db_fcrepo.this_db_instance_username
}

output "db_fcrepo_password" {
  value = module.db_fcrepo.this_db_instance_password
}

output "selected_subnets" {
  value = data.aws_subnet_ids.selected.ids
}

output "private_zone_id" {
  value = module.dns.private_zone_id
}

output "public_zone_id" {
  value = module.dns.public_zone_id
}