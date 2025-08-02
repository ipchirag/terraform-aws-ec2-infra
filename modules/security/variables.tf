variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_ssh_access" {
  description = "Enable SSH access to instances"
  type        = bool
  default     = true
}

variable "enable_http_access" {
  description = "Enable HTTP access to instances"
  type        = bool
  default     = true
}

variable "enable_https_access" {
  description = "Enable HTTPS access to instances"
  type        = bool
  default     = true
}

variable "application_ports" {
  description = "List of application ports to allow"
  type        = list(number)
  default     = [8080, 3000, 5000]
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for application data"
  type        = string
  default     = ""
}

variable "enable_cloudwatch_agent" {
  description = "Enable CloudWatch agent on instances"
  type        = bool
  default     = true
}

variable "enable_ssm" {
  description = "Enable Systems Manager on instances"
  type        = bool
  default     = true
}

variable "create_key_pair" {
  description = "Create a new key pair"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Public key for the key pair"
  type        = string
  default     = ""
}

variable "enable_kms" {
  description = "Enable KMS key for encryption"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
} 