# Local values for common configuration
locals {
  common_tags = merge(var.default_tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  })
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name           = var.project_name
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  enable_nat_gateway    = true
  tags                  = local.common_tags
}

# Security Module
module "security" {
  source = "./modules/security"

  project_name           = var.project_name
  vpc_id                = module.networking.vpc_id
  allowed_cidr_blocks   = var.allowed_cidr_blocks
  enable_ssh_access     = var.enable_ssh_access
  enable_http_access    = true
  enable_https_access   = var.enable_https_access
  application_ports     = [8080, 3000, 5000]
  enable_cloudwatch_agent = var.enable_cloudwatch_agent
  enable_ssm            = true
  create_key_pair       = var.key_name == ""
  public_key            = var.public_key
  enable_kms            = true
  tags                  = local.common_tags
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  project_name           = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  security_group_id     = module.security.ec2_security_group_id
  alb_security_group_id = module.security.alb_security_group_id
  instance_profile_name = module.security.ec2_instance_profile_name
  instance_type         = var.instance_type
  key_name              = var.key_name != "" ? var.key_name : module.security.key_pair_name
  root_volume_size      = var.root_volume_size
  root_volume_type      = var.root_volume_type
  enable_encryption     = true
  kms_key_id            = module.security.kms_key_id
  enable_cloudwatch_agent = var.enable_cloudwatch_agent
  enable_load_balancer  = var.enable_load_balancer
  load_balancer_type    = var.load_balancer_type
  health_check_path     = var.health_check_path
  health_check_port     = var.health_check_port
  enable_auto_scaling   = var.enable_auto_scaling
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.desired_capacity
  health_check_grace_period = var.health_check_grace_period
  enable_scaling_policies = true
  enable_scheduled_actions = var.enable_scheduled_actions
  tags                  = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  project_name              = var.project_name
  autoscaling_group_name    = module.compute.autoscaling_group_name
  load_balancer_name_suffix = module.compute.alb_id != null ? split("/", module.compute.alb_id)[1] : ""
  target_group_name         = module.compute.target_group_name
  enable_dashboard          = var.enable_cloudwatch_metrics
  enable_cloudwatch_logs    = var.enable_cloudwatch_logs
  enable_sns_notifications  = var.enable_sns_notifications
  enable_alarms             = var.enable_cloudwatch_metrics
  enable_autoscaling_events = true
  sns_email                 = var.sns_email
  log_retention_days        = 30
  cpu_threshold             = 80
  memory_threshold          = 85
  disk_threshold            = 85
  response_time_threshold   = 5
  error_rate_threshold      = 10
  min_healthy_instances     = var.min_size
  tags                      = local.common_tags
}

# Backup Module (if enabled)
module "backup" {
  count  = var.enable_backup ? 1 : 0
  source = "./modules/backup"

  project_name        = var.project_name
  environment         = var.environment
  autoscaling_group_name = module.compute.autoscaling_group_name
  retention_days      = var.backup_retention_days
  tags                = local.common_tags
} 