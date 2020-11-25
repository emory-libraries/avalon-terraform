data "aws_ami" "amzn" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["137112412989"] # Amazon
}

data "aws_iam_policy_document" "compose" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_policy" "this_bucket_policy" {
  name   = "${local.namespace}-compose-bucket-access"
  policy = data.aws_iam_policy_document.this_bucket_access.json
}

resource "aws_iam_instance_profile" "compose" {
  name = "${local.namespace}-compose-profile"
  role = aws_iam_role.compose.name
}

resource "aws_iam_role" "compose" {
  name               = "${local.namespace}-compose-role"
  force_detach_policies = true
  assume_role_policy = data.aws_iam_policy_document.compose.json
}

data "aws_iam_policy_document" "compose_api_access" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "elasticfilesystem:*",
      "elastictranscoder:List*",
      "elastictranscoder:Read*",
      "elastictranscoder:CreatePreset",
      "elastictranscoder:ListPresets",
      "elastictranscoder:ReadPreset",
      "elastictranscoder:ListJobs",
      "elastictranscoder:CreateJob",
      "elastictranscoder:ReadJob",
      "elastictranscoder:CancelJob",
      "s3:*",
      "cloudwatch:PutMetricData",
      "ssm:Get*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "compose_api_access" {
  name   = "${local.namespace}-compose-api-access"
  policy = data.aws_iam_policy_document.compose_api_access.json
}

resource "aws_iam_role_policy_attachment" "compose_api_access" {
  role       = aws_iam_role.compose.name
  policy_arn = aws_iam_policy.compose_api_access.arn
}

resource "aws_iam_role_policy_attachment" "compose_ecr_and_base_policies" {
  for_each   = toset(concat(["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"], var.base_policy_arns))
  role       = aws_iam_role.compose.name
  policy_arn = each.value
}

resource "aws_security_group" "compose" {
  name        = "${local.namespace}-compose"
  description = "Compose Host Security Group"
  vpc_id      = var.vpc_id
  tags        = local.common_tags
}

resource "aws_security_group_rule" "compose_web" {
  security_group_id = aws_security_group.compose.id
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
}

resource "aws_security_group_rule" "compose_streaming" {
  security_group_id = aws_security_group.compose.id
  type              = "ingress"
  from_port         = "8880"
  to_port           = "8880"
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
}

resource "aws_security_group_rule" "compose_ssh" {
  security_group_id = aws_security_group.compose.id
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = var.ssh_cidr_blocks
}

resource "aws_security_group_rule" "compose_egress" {
  security_group_id = aws_security_group.compose.id
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_this_redis_access" {
  security_group_id        = aws_security_group.redis.id
  type                     = "ingress"
  from_port                = aws_elasticache_cluster.redis.cache_nodes[0].port
  to_port                  = aws_elasticache_cluster.redis.cache_nodes[0].port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.compose.id
}

resource "aws_instance" "compose" {
  ami                         = data.aws_ami.amzn.id
  instance_type               = var.compose_instance_type
  key_name                    = var.ec2_keyname
  subnet_id                   = random_shuffle.random_subnet.result.0
  iam_instance_profile        = aws_iam_instance_profile.compose.name
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.namespace}-compose"
    },
  )

  root_block_device {
    volume_size = "50"
    volume_type = "standard"
  }

  user_data = file("scripts/attach_ebs.sh")

  vpc_security_group_ids = [
    aws_security_group.compose.id,
    aws_security_group.db_client.id,
  ]

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "null_resource" "install_docker_on_compose" {
  triggers = {
    host = aws_instance.compose.id
  }

  provisioner "file" {
    connection {
      host        = aws_instance.compose.private_ip
      user        = "ec2-user"
      agent       = true
      timeout     = "10m"
      private_key = file(var.ec2_private_keyfile)
    }

    content = <<EOF
FEDORA_OPTIONS=-Dfcrepo.postgresql.host=${module.db_fcrepo.this_db_instance_address} -Dfcrepo.postgresql.username=${module.db_fcrepo.this_db_instance_username} -Dfcrepo.postgresql.password=${module.db_fcrepo.this_db_instance_password} -Dfcrepo.postgresql.port=${module.db_fcrepo.this_db_instance_port} -Daws.accessKeyId=${var.fcrepo_binary_bucket_access_key} -Daws.secretKey=${var.fcrepo_binary_bucket_secret_key} -Daws.bucket=${aws_s3_bucket.fcrepo_binary_bucket.id}
FEDORA_LOGGROUP=${aws_cloudwatch_log_group.compose_log_group.name}/fedora.log

SOLR_LOGGROUP=${aws_cloudwatch_log_group.compose_log_group.name}/solr.log

HLS_LOGGROUP=${aws_cloudwatch_log_group.compose_log_group.name}/hls.log
AVALON_STREAMING_BUCKET=${aws_s3_bucket.this_derivatives.id}
AVALON_LOGGROUP=${aws_cloudwatch_log_group.compose_log_group.name}/avalon.log
WORKER_LOGGROUP=${aws_cloudwatch_log_group.compose_log_group.name}/worker.log
AVALON_DOCKER_REPO=${aws_ecr_repository.avalon.repository_url}
AVALON_REPO=${var.avalon_repo}
DATABASE_URL=postgres://${module.db_avalon.this_db_instance_username}:${module.db_avalon.this_db_instance_password}@${module.db_avalon.this_db_instance_address}/avalon
ELASTICACHE_HOST=${aws_route53_record.redis.name}
SECRET_KEY_BASE=${var.secret_key_base}
AVALON_BRANCH=${var.avalon_branch}
AWS_REGION=${var.aws_region}
RAILS_LOG_TO_STDOUT=true
SETTINGS__DOMAIN=https://${local.appended_fqdn}
SETTINGS__DROPBOX__PATH=s3://${aws_s3_bucket.this_masterfiles.id}/dropbox/
SETTINGS__DROPBOX__UPLOAD_URI=s3://${aws_s3_bucket.this_masterfiles.id}/dropbox/
SETTINGS__MASTER_FILE_MANAGEMENT__PATH=s3://${aws_s3_bucket.this_preservation.id}/
SETTINGS__MASTER_FILE_MANAGEMENT__STRATEGY=MOVE
SETTINGS__ENCODING__ENGINE_ADAPTER=elastic_transcoder
SETTINGS__ENCODING__PIPELINE=${aws_elastictranscoder_pipeline.this_pipeline.id}
SETTINGS__EMAIL__COMMENTS=${var.email_comments}
SETTINGS__EMAIL__NOTIFICATION=${var.email_notification}
SETTINGS__EMAIL__SUPPORT=${var.email_support}
STREAMING_HOST=${local.streaming_appended_fqdn}
SETTINGS__STREAMING__HTTP_BASE=https://${local.streaming_appended_fqdn}/avalon
SETTINGS__TIMELINER__TIMELINER_URL=https://${local.appended_fqdn}/timeliner
SETTINGS__INITIAL_USER=${var.avalon_admin}
##### LTI Integration Variables ################
LTI_AUTH_KEY=${var.lti_auth_key}
LTI_AUTH_SECRET=${var.lti_auth_secret}
################################################
##### Shibboleth Environment Variables #########
ADMIN_LDAP_GROUPS="${join(",", var.admin_ldap_groups)}"
ASSERTION_CS_URL=${var.assertion_cs_url}
ASSERTION_LOGOUT_URL=${var.assertion_logout_url}
IDP_SLO_TARGET_URL=${var.idp_slo_target_url}
ISSUER=${var.issuer}
IDP_SSO_TARGET_URL=${var.idp_sso_target_url}
IDP_CERT="${replace(file(var.idp_cert_file), "\n", "\\n")}"
SP_CERT="${replace(file(var.sp_cert_file), "\n", "\\n")}"
SP_KEY="${replace(file(var.sp_key_file), "\n", "\\n")}"
################################################
EOF

    destination = "/tmp/.env"
  }

  provisioner "remote-exec" {
    connection {
      host        = aws_instance.compose.private_ip
      user        = "ec2-user"
      agent       = true
      timeout     = "10m"
      private_key = file(var.ec2_private_keyfile)
    }

    inline = [
      "echo '${aws_efs_file_system.solr_backups.id}:/ /srv/solr_backups efs defaults,_netdev 0 0' | sudo tee -a /etc/fstab",
      "sudo mkdir -p /srv/solr_backups && sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.solr_backups.dns_name}:/ /srv/solr_backups",
      "sudo chown 8983:8983 /srv/solr_backups",
      "sudo yum install -y docker && sudo usermod -a -G docker ec2-user && sudo systemctl enable --now docker",
      "sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "wget https://github.com/avalonmediasystem/avalon-docker/archive/aws_min.zip && unzip aws_min.zip",
      "cd avalon-docker-aws_min && cp /tmp/.env .",
    ]
  }

  provisioner "local-exec" {
    command = "aws codebuild start-build --project-name ${aws_codebuild_project.docker.name} --profile ${var.aws_profile} --region ${var.aws_region}"
  }
}

resource "aws_s3_bucket_policy" "compose-s3" {
  bucket = aws_s3_bucket.this_derivatives.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.this_derivatives.id}/*",
      "Condition": {
         "IpAddress": {"aws:SourceIp": "${aws_instance.compose.private_ip}"}
      }
    }
  ]
}
POLICY

}

resource "aws_cloudwatch_log_group" "compose_log_group" {
  name = local.namespace
}

resource "aws_volume_attachment" "compose_solr" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.solr_data.id
  instance_id = aws_instance.compose.id
}

resource "aws_ebs_volume" "solr_data" {
  availability_zone = data.aws_subnet.random.availability_zone
  size              = 20
}

