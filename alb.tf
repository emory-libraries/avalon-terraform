resource "aws_alb" "alb" {
  name = "${local.namespace}-alb"
  subnets         = data.aws_subnet_ids.selected.ids
  security_groups = [aws_security_group.alb.id]
  internal        = true  
  idle_timeout = "300"
  #   tags {    
  #     Name    = "${var.alb_name}"    
  #   }   
  #   access_logs {    
  #     bucket = "${var.s3_bucket}"    
  #     prefix = "ELB-logs"  
  #   }
}

# Security group and rules
resource "aws_security_group" "alb" {
  name        = "${local.namespace}-alb"
  description = "Compose Host Security Group"
  vpc_id      = var.vpc_id
  tags        = local.common_tags
}

resource "aws_security_group_rule" "alb_ingress" {
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = "80"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Domain names for web and streaming endpoints
resource "aws_route53_record" "alb" {
  zone_id = module.dns.public_zone_id
  name    = local.public_zone_name
  type    = "A"

  alias {
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alb_streaming" {
  zone_id = module.dns.public_zone_id
  name    = "streaming.${local.public_zone_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb.dns_name]
}

resource "aws_lb_listener" "alb_forward_https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.web_streaming_cert.arn

  default_action {
    type             = "fixed-response"
  }
  
  fixed_response {
    content_type = "text/plain"
    message_body = "Emory University Libraries"
    status_code  = "200"
  }
}

# Web listener rule and target group
resource "aws_lb_listener_rule" "alb_web_listener_rule" {
  listener_arn = aws_alb_listener.alb_listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_web.arn
  }

  condition {
    host_header {
      values = [local.appended_fqdn]
    }
  }
}

resource "aws_alb_target_group" "alb_web" {
  name     = "${local.namespace}-alb-web"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = "true"
  }
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    path                = "/"
    port                = "80"
  }
}

# Streaming listener rule and target group
resource "aws_lb_listener_rule" "alb_streaming_listener_rule" {
  listener_arn = aws_alb_listener.alb_listener.arn
  priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_streaming.arn
  }

  condition {
      host_header {
        values = [local.streaming_appended_fqdn]
    }
  }
}

resource "aws_alb_target_group" "alb_streaming" {
  name     = "${local.namespace}-alb-streaming"
  port     = "8880"
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = "true"
  }
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    path                = "/status"
    port                = "8880"
  }
}

# Import web and streaming certificate 
resource "aws_acm_certificate" "web_streaming_cert" {
  private_key = file(var.private_key_file)
  certificate_body = file(var.certificate_body_file)
  certificate_chain = file(var.certificate_chain_file)
  
  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_certificate" "alb_streaming" {
  listener_arn    = aws_alb_listener.alb_listener.arn
  certificate_arn = aws_acm_certificate.web_streaming_cert.arn
}

#Instance Attachment
resource "aws_alb_target_group_attachment" "alb_compose" {
  target_group_arn = aws_alb_target_group.alb_web.arn
  target_id        = aws_instance.compose.id
  port             = 80
}

resource "aws_alb_target_group_attachment" "alb_compose_streaming" {
  target_group_arn = aws_alb_target_group.alb_streaming.arn
  target_id        = aws_instance.compose.id
  port             = 8880
}

