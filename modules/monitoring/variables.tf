variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
  default     = ""
}

variable "load_balancer_name_suffix" {
  description = "Name suffix of the load balancer"
  type        = string
  default     = ""
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
  default     = ""
}

variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs"
  type        = bool
  default     = true
}

variable "enable_sns_notifications" {
  description = "Enable SNS notifications"
  type        = bool
  default     = true
}

variable "enable_alarms" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = true
}

variable "enable_autoscaling_events" {
  description = "Enable Auto Scaling event monitoring"
  type        = bool
  default     = true
}

variable "sns_email" {
  description = "Email address for SNS notifications"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for alarms"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "Memory utilization threshold for alarms"
  type        = number
  default     = 85
}

variable "disk_threshold" {
  description = "Disk utilization threshold for alarms"
  type        = number
  default     = 85
}

variable "response_time_threshold" {
  description = "Response time threshold for alarms"
  type        = number
  default     = 5
}

variable "error_rate_threshold" {
  description = "Error rate threshold for alarms"
  type        = number
  default     = 10
}

variable "min_healthy_instances" {
  description = "Minimum number of healthy instances"
  type        = number
  default     = 1
}

variable "custom_alarms" {
  description = "Map of custom CloudWatch alarms"
  type = map(object({
    comparison_operator = string
    evaluation_periods  = string
    metric_name         = string
    namespace           = string
    period              = string
    statistic           = string
    threshold           = number
    description         = string
    dimensions = list(object({
      name  = string
      value = string
    }))
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
} 