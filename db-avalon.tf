module "db_avalon_password" {
  source = "./modules/password"
}

module "db_avalon" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.9.0"

  identifier = "${local.namespace}-avalon-db"

  engine         = "postgres"
  engine_version = var.postgres_version

  instance_class    = "db.t3.micro"
  allocated_storage = 20
  
  name     = "avalon"
  username = var.db_avalon_username
  password = module.db_avalon_password.result
  port     = 5432

  option_group_name       = "default:postgres-10"
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 35
  copy_tags_to_snapshot   = true

  vpc_security_group_ids = [aws_security_group.db.id]
  subnet_ids = data.aws_subnet_ids.selected.ids

  tags = local.common_tags
  family = "postgres10"

  apply_immediately = true
  
  parameters = [
    {
      name  = "client_encoding"
      value = "UTF8"
    },
    {
      name  = "rds.force_ssl"
      value = 1
    }
  ]
  storage_encrypted = true
}
/* 
SSM is not available in aws@emory
resource "aws_ssm_parameter" "db_avalon_host" {
  name      = "/${local.namespace}-avalon-db/host"
  value     = module.db_avalon.this_db_instance_address
  type      = "String"
  overwrite = true
}

resource "aws_ssm_parameter" "db_avalon_port" {
  name      = "/${local.namespace}-avalon-db/port"
  value     = module.db_avalon.this_db_instance_port
  type      = "String"
  overwrite = true
}

resource "aws_ssm_parameter" "db_avalon_admin_user" {
  name      = "/${local.namespace}-avalon-db/admin_user"
  value     = module.db_avalon.this_db_instance_username
  type      = "SecureString"
  overwrite = true
}

resource "aws_ssm_parameter" "db_avalon_admin_password" {
  name      = "/${local.namespace}-avalon-db/admin_password"
  value     = module.db_avalon.this_db_instance_password
  type      = "SecureString"
  overwrite = true
}
 */
