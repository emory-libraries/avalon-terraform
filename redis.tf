resource "aws_security_group" "redis" {
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "redis_egress" {
  security_group_id = aws_security_group.redis.id
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_elasticache_subnet_group" "redis" {
  name = "${local.namespace}-redis"
  subnet_ids = data.aws_subnet_ids.selected.ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${local.namespace}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  engine_version       = "5.0.3"
  parameter_group_name = "default.redis5.0"
  security_group_ids   = [aws_security_group.redis.id]
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
}

resource "aws_route53_record" "redis" {
  zone_id = module.dns.private_zone_id
  name    = "redis.${local.private_zone_name}"
  type    = "CNAME"
  ttl     = 900
  records = [aws_elasticache_cluster.redis.cache_nodes[0].address]
}

