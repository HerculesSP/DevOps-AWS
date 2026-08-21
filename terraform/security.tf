resource "aws_security_group" "bastion" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_security_group" "lb" {
  name   = "lb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "lb-sg"
  }
}

resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

resource "aws_security_group" "app" {
  name   = "app-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}

resource "aws_security_group" "db" {
  name   = "db-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

resource "aws_wafv2_web_acl" "main" {
  name        = "main-alb-waf"
  description = "WAF para ALB: geo-block Brasil, rate limit anti-DDoS, SQLi e known bad inputs"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Respostas customizadas
  custom_response_body {
    key          = "geo_blocked"
    content_type = "APPLICATION_JSON"
    content = jsonencode({
      error   = "access_denied"
      message = "Este serviço está disponível apenas para requisições originadas no Brasil."
      code    = "GEO_RESTRICTED"
    })
  }

  custom_response_body {
    key          = "rate_limited"
    content_type = "APPLICATION_JSON"
    content = jsonencode({
      error   = "too_many_requests"
      message = "Limite de requisições excedido. Tente novamente em instantes."
      code    = "RATE_LIMIT_EXCEEDED"
    })
  }

  custom_response_body {
    key          = "body_too_large"
    content_type = "APPLICATION_JSON"
    content = jsonencode({
      error   = "payload_too_large"
      message = "O corpo da requisição excede o tamanho permitido."
      code    = "REQUEST_BODY_TOO_LARGE"
    })
  }

  custom_response_body {
    key          = "ddos_blocked"
    content_type = "APPLICATION_JSON"
    content = jsonencode({
      error   = "forbidden"
      message = "Requisição bloqueada por comportamento suspeito."
      code    = "DDOS_PROTECTION"
    })
  }

  # 1. Geo-block: apenas Brasil (primeira linha de defesa)
  rule {
    name     = "BlockNonBrazilTraffic"
    priority = 0

    action {
      block {
        custom_response {
          response_code            = 403
          custom_response_body_key = "geo_blocked"
        }
      }
    }

    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = ["BR"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockNonBrazilTraffic"
      sampled_requests_enabled   = true
    }
  }

  # 2. Rate limit agressivo por IP (anti-DDoS L7)
  # Bloqueia após 500 requisições por minuto do mesmo IP
  rule {
    name     = "RateLimitPerIpAggressive"
    priority = 5

    action {
      block {
        custom_response {
          response_code            = 429
          custom_response_body_key = "rate_limited"

          response_header {
            name  = "retry-after"
            value = "60"
          }
        }
      }
    }

    statement {
      rate_based_statement {
        limit                 = 500
        aggregate_key_type    = "IP"
        evaluation_window_sec = 60
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitPerIpAggressive"
      sampled_requests_enabled   = true
    }
  }

  # 3. Rate limit moderado por IP (para picos legítimos)
  # Bloqueia após 2000 requisições em 5 minutos
  rule {
    name     = "RateLimitPerIpModerate"
    priority = 10

    action {
      block {
        custom_response {
          response_code            = 429
          custom_response_body_key = "rate_limited"
        }
      }
    }

    statement {
      rate_based_statement {
        limit                 = 2000
        aggregate_key_type    = "IP"
        evaluation_window_sec = 300
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitPerIpModerate"
      sampled_requests_enabled   = true
    }
  }

  # 4. Tamanho máximo do body (8KB)
  rule {
    name     = "BlockLargeRequestBodies"
    priority = 20

    action {
      block {
        custom_response {
          response_code            = 413
          custom_response_body_key = "body_too_large"
        }
      }
    }

    statement {
      size_constraint_statement {
        comparison_operator = "GT"
        size                = 8192

        field_to_match {
          body {
            oversize_handling = "MATCH"
          }
        }

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockLargeRequestBodies"
      sampled_requests_enabled   = true
    }
  }

  # 5. Known Bad Inputs (AWS Managed Rule)
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  # 6. SQL Injection (AWS Managed Rule)
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 40

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiProtection"
      sampled_requests_enabled   = true
    }
  }

  # 7. Common Rule Set (OWASP)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 50

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "main-alb-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "main-alb-waf"
  }
}

# Associação do WAF ao ALB
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}


output "alb_dns_name" {
  description = "DNS do ALB"
  value       = aws_lb.main.dns_name
}