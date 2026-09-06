resource "aws_wafv2_web_acl" "main" {
  name        = "main-alb-waf"
  description = "WAF para ALB: geo-block Brasil, rate limit anti-DDoS, SQLi e known bad inputs"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

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

/*  rule {
    name     = "AllowHealthChecks"
    priority = 0

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        search_string = "/api/health"
        field_to_match {
          uri_path {}
        }
        text_transformation {
          priority = 0
          type     = "URL_DECODE"
        }
        positional_constraint = "STARTS_WITH"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowHealthChecks"
      sampled_requests_enabled   = true
    }
  }
*/
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

  rule {
    name     = "AllowLargeBodies14MB"
    priority = 15

    statement {
      and_statement {
        statement {
          or_statement {
            statement {
              byte_match_statement {
                search_string = "/imagem"
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 0
                  type     = "URL_DECODE"
                }
                positional_constraint = "ENDS_WITH"
              }
            }
            statement {
              byte_match_statement {
                search_string = "/nota"
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 0
                  type     = "URL_DECODE"
                }
                positional_constraint = "ENDS_WITH"
              }
            }
          }
        }
        statement {
          size_constraint_statement {
            comparison_operator = "GT"
            size                = 14680064

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
      }
    }

    action {
      block {
        custom_response {
          response_code            = 413
          custom_response_body_key = "body_too_large"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowLargeBodies14MB"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "BlockLargeRequestBodies16KB"
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
        size                = 16384

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
      metric_name                = "BlockLargeRequestBodies16KB"
      sampled_requests_enabled   = true
    }
  }

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

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}


output "alb_dns_name" {
  description = "DNS do ALB"
  value       = aws_lb.main.dns_name
}