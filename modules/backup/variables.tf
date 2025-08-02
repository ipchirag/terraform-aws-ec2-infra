variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
  default     = ""
}

variable "retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "destination_vault_arn" {
  description = "ARN of the destination backup vault for cross-region backup"
  type        = string
  default     = ""
}

variable "enable_cross_region_backup" {
  description = "Enable cross-region backup"
  type        = bool
  default     = false
}

variable "enable_ebs_snapshots" {
  description = "Enable EBS snapshots"
  type        = bool
  default     = true
}

variable "enable_s3_backup" {
  description = "Enable S3 backup"
  type        = bool
  default     = false
}

variable "volume_id" {
  description = "Volume ID for EBS snapshot"
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
} 