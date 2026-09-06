resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "pezaosound-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "Target Group app - HTTP 5XX"
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          stat    = "Sum"
          period  = 60
          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_Target_5XX_Count",
              "TargetGroup",
              aws_lb_target_group.app.arn_suffix,
              "LoadBalancer",
              aws_lb.main.arn_suffix
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "Target Group web - Healthy Hosts"
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          stat    = "Minimum"
          period  = 60
          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "TargetGroup",
              aws_lb_target_group.web.arn_suffix,
              "LoadBalancer",
              aws_lb.main.arn_suffix
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "Target Group app - Healthy Hosts"
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          stat    = "Minimum"
          period  = 60
          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "TargetGroup",
              aws_lb_target_group.app.arn_suffix,
              "LoadBalancer",
              aws_lb.main.arn_suffix
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title   = "RDS - CPU Utilization"
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          stat    = "Average"
          period  = 60
          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              "InstanceId",
              aws_db_instance.instance_db.id
            ]
          ]
        }
      }
    ]
  })
}

resource "aws_sns_topic" "alerts" {
  name = "alb-healthy-hosts-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "healthy_hosts_below_threshold" {
  for_each = local.healthy_host_alarms

  alarm_name          = "${each.key}-healthy-hosts-below-${each.value.threshold}"
  alarm_description   = "Dispara quando o target group ${each.key} ficar com menos de ${each.value.threshold} instancias saudaveis"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = each.value.threshold
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Minimum"
  treat_missing_data  = "breaching"

  dimensions = {
    TargetGroup  = each.value.target_group_arn_suffix
    LoadBalancer = aws_lb.main.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "db_cpu_high" {
  alarm_name          = "db-cpu-above-85"
  alarm_description   = "Dispara quando a CPU do RDS ficar acima de 85%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 85
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  treat_missing_data  = "missing"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.instance_db.id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}