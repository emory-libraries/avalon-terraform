module "dns" {
  source = "github.com/infrablocks/terraform-aws-dns-zones"

  domain_name         = local.public_zone_name
  private_domain_name = local.private_zone_name

  # Default VPC
  private_zone_vpc_id     = var.vpc_id
  private_zone_vpc_region = var.aws_region
}

data "aws_route53_zone" "hosted_zone" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "public_zone" {
  zone_id = data.aws_route53_zone.hosted_zone.id
  type    = "NS"
  name    = local.public_zone_name
  records = module.dns.public_zone_name_servers
  ttl     = 300
}