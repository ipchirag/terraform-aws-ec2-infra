# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  count          = var.enable_dashboard ? 1 : 0
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.autoscaling_group_name],
            [".", "NetworkIn", ".", "."],
            [".", "NetworkOut", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "EC2 Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.load_balancer_name_suffix],
            [".", "TargetResponseTime", ".", "."],
            [".", "HTTPCode_Target_5XX_Count", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Load Balancer Metrics"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6

        properties = {
          query   = "SOURCE '/aws/ec2/${var.project_name}/system'\n| fields @timestamp, @message\n| filter @message like /ERROR/\n| sort @timestamp desc\n| limit 20"
          region  = data.aws_region.current.name
          title   = "System Logs - Errors"
          view    = "table"
        }
      }
    ]
  })
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "system" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/ec2/${var.project_name}/system"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "security" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/ec2/${var.project_name}/security"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "nginx_access" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/ec2/${var.project_name}/nginx/access"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "nginx_error" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/ec2/${var.project_name}/nginx/error"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "application" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/ec2/${var.project_name}/application"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# SNS Topic for notifications
resource "aws_sns_topic" "alerts" {
  count = var.enable_sns_notifications ? 1 : 0
  name  = "${var.project_name}-alerts"

  tags = var.tags
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "email" {
  count     = var.enable_sns_notifications && var.sns_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.sns_email
}

# CloudWatch Alarms

# High CPU Alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  tags = var.tags
}

# High Memory Alarm
resource "aws_cloudwatch_metric_alarm" "high_memory" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project_name}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_threshold
  alarm_description   = "This metric monitors memory utilization"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  tags = var.tags
}

# High Disk Alarm
resource "aws_cloudwatch_metric_alarm" "high_disk" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project_name}-high-disk"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = var.disk_threshold
  alarm_description   = "This metric monitors disk utilization"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  tags = var.tags
}

# Load Balancer High Response Time Alarm
resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  count               = var.enable_alarms && var.load_balancer_name_suffix != "" ? 1 : 0
  alarm_name          = "${var.project_name}-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = var.response_time_threshold
  alarm_description   = "This metric monitors load balancer response time"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    LoadBalancer = var.load_balancer_name_suffix
  }

  tags = var.tags
}

# Load Balancer High Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  count               = var.enable_alarms && var.load_balancer_name_suffix != "" ? 1 : 0
  alarm_name          = "${var.project_name}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.error_rate_threshold
  alarm_description   = "This metric monitors load balancer 5XX errors"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    LoadBalancer = var.load_balancer_name_suffix
  }

  tags = var.tags
}

# Instance Health Check Alarm
resource "aws_cloudwatch_metric_alarm" "instance_health" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project_name}-instance-health"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = var.min_healthy_instances
  alarm_description   = "This metric monitors healthy instance count"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    TargetGroup  = var.target_group_name
    LoadBalancer = var.load_balancer_name_suffix
  }

  tags = var.tags
}

# Custom Metrics Alarm
resource "aws_cloudwatch_metric_alarm" "custom_metric" {
  for_each            = var.custom_alarms
  alarm_name          = "${var.project_name}-${each.key}"
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.description
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

  dynamic "dimensions" {
    for_each = each.value.dimensions
    content {
      name  = dimensions.value.name
      value = dimensions.value.value
    }
  }

  tags = var.tags
}

# CloudWatch Event Rule for Auto Scaling Events
resource "aws_cloudwatch_event_rule" "autoscaling_events" {
  count       = var.enable_autoscaling_events ? 1 : 0
  name        = "${var.project_name}-autoscaling-events"
  description = "Capture Auto Scaling events"

  event_pattern = jsonencode({
    source      = ["aws.autoscaling"]
    detail-type = ["EC2 Instance Launch Successful", "EC2 Instance Launch Unsuccessful", "EC2 Instance Terminate Successful", "EC2 Instance Terminate Unsuccessful"]
    detail = {
      "AutoScalingGroupName" = [var.autoscaling_group_name]
    }
  })

  tags = var.tags
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "autoscaling_events" {
  count     = var.enable_autoscaling_events && var.enable_sns_notifications ? 1 : 0
  rule      = aws_cloudwatch_event_rule.autoscaling_events[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.alerts[0].arn
}

# Data source for current region
data "aws_region" "current" {} 