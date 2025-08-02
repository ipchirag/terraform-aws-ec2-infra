# Global Variables
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "production-ec2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "production-ec2"
    ManagedBy   = "terraform"
    Environment = "dev"
  }
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

# Compute Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 2
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "Volume type must be one of: gp2, gp3, io1, io2."
  }
}

variable "enable_spot_instances" {
  description = "Enable spot instances for cost optimization"
  type        = bool
  default     = false
}

# Security Variables
variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = ""
}

variable "enable_ssh_access" {
  description = "Enable SSH access to instances"
  type        = bool
  default     = true
}

variable "enable_https_access" {
  description = "Enable HTTPS access to instances"
  type        = bool
  default     = true
}

# Monitoring Variables
variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_metrics" {
  description = "Enable CloudWatch metrics"
  type        = bool
  default     = true
}

variable "enable_sns_notifications" {
  description = "Enable SNS notifications"
  type        = bool
  default     = true
}

variable "sns_email" {
  description = "Email address for SNS notifications"
  type        = string
  default     = ""
}

# Auto Scaling Variables
variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Group"
  type        = bool
  default     = true
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 5
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

# Load Balancer Variables
variable "enable_load_balancer" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true
}

variable "load_balancer_type" {
  description = "Type of load balancer"
  type        = string
  default     = "application"
  validation {
    condition     = contains(["application", "network"], var.load_balancer_type)
    error_message = "Load balancer type must be one of: application, network."
  }
}

variable "health_check_path" {
  description = "Health check path for the load balancer"
  type        = string
  default     = "/health"
}

variable "health_check_port" {
  description = "Health check port for the load balancer"
  type        = string
  default     = "80"
}

# Backup Variables
variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

# Cost Optimization Variables
variable "enable_cost_optimization" {
  description = "Enable cost optimization features"
  type        = bool
  default     = true
}

variable "enable_scheduled_actions" {
  description = "Enable scheduled actions for cost optimization"
  type        = bool
  default     = false
} 