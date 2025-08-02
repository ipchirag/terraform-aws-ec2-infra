# Networking Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = module.networking.database_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.networking.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = module.networking.nat_gateway_public_ip
}

# Security Outputs
output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = module.security.ec2_security_group_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.security.alb_security_group_id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = module.security.rds_security_group_id
}

output "ec2_iam_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = module.security.ec2_iam_role_arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.security.ec2_instance_profile_name
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = module.security.key_pair_name
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = module.security.kms_key_arn
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = module.security.kms_key_id
}

# Compute Outputs
output "launch_template_id" {
  description = "ID of the launch template"
  value       = module.compute.launch_template_id
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = module.compute.launch_template_arn
}

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = module.compute.alb_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.compute.alb_arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.compute.alb_zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.compute.target_group_arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = module.compute.target_group_name
}

output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = module.compute.autoscaling_group_id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.compute.autoscaling_group_arn
}

output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = module.compute.scale_up_policy_arn
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = module.compute.scale_down_policy_arn
}

output "high_cpu_alarm_arn" {
  description = "ARN of the high CPU alarm"
  value       = module.compute.high_cpu_alarm_arn
}

output "low_cpu_alarm_arn" {
  description = "ARN of the low CPU alarm"
  value       = module.compute.low_cpu_alarm_arn
}

# Monitoring Outputs
output "cloudwatch_dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = module.monitoring.dashboard_arn
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = module.monitoring.dashboard_name
}

output "cloudwatch_log_group_names" {
  description = "Names of the CloudWatch log groups"
  value       = module.monitoring.log_group_names
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = module.monitoring.sns_topic_arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = module.monitoring.sns_topic_name
}

output "cloudwatch_alarm_arns" {
  description = "ARNs of the CloudWatch alarms"
  value       = module.monitoring.alarm_arns
}

output "custom_alarm_arns" {
  description = "ARNs of the custom CloudWatch alarms"
  value       = module.monitoring.custom_alarm_arns
}

output "event_rule_arn" {
  description = "ARN of the CloudWatch event rule"
  value       = module.monitoring.event_rule_arn
}

# Backup Outputs
output "backup_vault_arn" {
  description = "ARN of the backup vault"
  value       = var.enable_backup ? module.backup[0].backup_vault_arn : null
}

output "backup_plan_arn" {
  description = "ARN of the backup plan"
  value       = var.enable_backup ? module.backup[0].backup_plan_arn : null
}

# Summary Outputs
output "infrastructure_summary" {
  description = "Summary of the deployed infrastructure"
  value = {
    project_name     = var.project_name
    environment      = var.environment
    region           = var.aws_region
    vpc_id           = module.networking.vpc_id
    alb_dns_name     = module.compute.alb_dns_name
    autoscaling_group_name = module.compute.autoscaling_group_name
    dashboard_name   = module.monitoring.dashboard_name
    sns_topic_name   = module.monitoring.sns_topic_name
    key_pair_name    = module.security.key_pair_name
    kms_key_id       = module.security.kms_key_id
  }
}

output "access_information" {
  description = "Information for accessing the infrastructure"
  value = {
    load_balancer_url = module.compute.alb_dns_name != null ? "http://${module.compute.alb_dns_name}" : "No load balancer"
    health_check_url  = module.compute.alb_dns_name != null ? "http://${module.compute.alb_dns_name}/health" : "No load balancer"
    cloudwatch_dashboard = module.monitoring.dashboard_name != null ? "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${module.monitoring.dashboard_name}" : "No dashboard"
    ssh_command       = module.security.key_pair_name != null ? "ssh -i ~/.ssh/${module.security.key_pair_name}.pem ec2-user@<instance-ip>" : "No key pair"
  }
} 