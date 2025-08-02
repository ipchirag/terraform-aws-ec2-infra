output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.main.id
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = aws_launch_template.main.arn
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.main.latest_version
}

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.main[0].id : null
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.main[0].arn : null
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.main[0].dns_name : null
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.main[0].zone_id : null
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = var.enable_load_balancer ? aws_lb_target_group.main[0].arn : null
}

output "target_group_name" {
  description = "Name of the target group"
  value       = var.enable_load_balancer ? aws_lb_target_group.main[0].name : null
}

output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = var.enable_auto_scaling ? aws_autoscaling_group.main[0].id : null
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = var.enable_auto_scaling ? aws_autoscaling_group.main[0].name : null
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = var.enable_auto_scaling ? aws_autoscaling_group.main[0].arn : null
}

output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = var.enable_auto_scaling && var.enable_scaling_policies ? aws_autoscaling_policy.scale_up[0].arn : null
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = var.enable_auto_scaling && var.enable_scaling_policies ? aws_autoscaling_policy.scale_down[0].arn : null
}

output "high_cpu_alarm_arn" {
  description = "ARN of the high CPU alarm"
  value       = var.enable_auto_scaling && var.enable_scaling_policies ? aws_cloudwatch_metric_alarm.high_cpu[0].arn : null
}

output "low_cpu_alarm_arn" {
  description = "ARN of the low CPU alarm"
  value       = var.enable_auto_scaling && var.enable_scaling_policies ? aws_cloudwatch_metric_alarm.low_cpu[0].arn : null
} 