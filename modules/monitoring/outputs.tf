output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = var.enable_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_arn : null
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = var.enable_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_name : null
}

output "log_group_names" {
  description = "Names of the CloudWatch log groups"
  value = var.enable_cloudwatch_logs ? {
    system      = aws_cloudwatch_log_group.system[0].name
    security    = aws_cloudwatch_log_group.security[0].name
    nginx_access = aws_cloudwatch_log_group.nginx_access[0].name
    nginx_error  = aws_cloudwatch_log_group.nginx_error[0].name
    application = aws_cloudwatch_log_group.application[0].name
  } : {}
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = var.enable_sns_notifications ? aws_sns_topic.alerts[0].arn : null
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = var.enable_sns_notifications ? aws_sns_topic.alerts[0].name : null
}

output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms"
  value = var.enable_alarms ? {
    high_cpu         = aws_cloudwatch_metric_alarm.high_cpu[0].arn
    high_memory      = aws_cloudwatch_metric_alarm.high_memory[0].arn
    high_disk        = aws_cloudwatch_metric_alarm.high_disk[0].arn
    high_response_time = var.load_balancer_name_suffix != "" ? aws_cloudwatch_metric_alarm.high_response_time[0].arn : null
    high_error_rate  = var.load_balancer_name_suffix != "" ? aws_cloudwatch_metric_alarm.high_error_rate[0].arn : null
    instance_health  = aws_cloudwatch_metric_alarm.instance_health[0].arn
  } : {}
}

output "custom_alarm_arns" {
  description = "ARNs of the custom CloudWatch alarms"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.custom_metric : k => v.arn
  }
}

output "event_rule_arn" {
  description = "ARN of the CloudWatch event rule"
  value       = var.enable_autoscaling_events ? aws_cloudwatch_event_rule.autoscaling_events[0].arn : null
} 