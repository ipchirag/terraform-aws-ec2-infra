# AWS Backup Vault
resource "aws_backup_vault" "main" {
  name = "${var.project_name}-backup-vault"

  tags = var.tags
}

# AWS Backup Plan
resource "aws_backup_plan" "main" {
  name = "${var.project_name}-backup-plan"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.main.name

    schedule = "cron(0 2 * * ? *)" # Daily at 2 AM UTC

    lifecycle {
      delete_after = var.retention_days
    }

    copy_action {
      destination_vault_arn = var.destination_vault_arn
    }
  }

  rule {
    rule_name         = "weekly_backup"
    target_vault_name = aws_backup_vault.main.name

    schedule = "cron(0 3 ? * SUN *)" # Weekly on Sunday at 3 AM UTC

    lifecycle {
      delete_after = var.retention_days * 4 # Keep weekly backups longer
    }
  }

  rule {
    rule_name         = "monthly_backup"
    target_vault_name = aws_backup_vault.main.name

    schedule = "cron(0 4 1 * ? *)" # Monthly on the 1st at 4 AM UTC

    lifecycle {
      delete_after = var.retention_days * 12 # Keep monthly backups for a year
    }
  }

  tags = var.tags
}

# AWS Backup Selection
resource "aws_backup_selection" "main" {
  name         = "${var.project_name}-backup-selection"
  plan_id      = aws_backup_plan.main.id
  iam_role_arn = aws_iam_role.backup.arn

  resources = [
    "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*",
    "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:volume/*",
    "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:*"
  ]

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Project"
    value = var.project_name
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Environment"
    value = var.environment
  }
}

# IAM Role for AWS Backup
resource "aws_iam_role" "backup" {
  name = "${var.project_name}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for AWS Backup
resource "aws_iam_role_policy_attachment" "backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup.name
}

# IAM Policy for AWS Backup Restore
resource "aws_iam_role_policy_attachment" "backup_restore" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup.name
}

# EBS Snapshot Policy
resource "aws_ebs_snapshot_copy" "main" {
  count           = var.enable_cross_region_backup ? 1 : 0
  description     = "Cross-region backup for ${var.project_name}"
  source_region   = data.aws_region.current.name
  source_snapshot_id = aws_ebs_snapshot.main.id
  encrypted       = true
  kms_key_id      = var.kms_key_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-cross-region-snapshot"
  })
}

# EBS Snapshot
resource "aws_ebs_snapshot" "main" {
  count     = var.enable_ebs_snapshots ? 1 : 0
  volume_id = var.volume_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-snapshot"
  })
}

# S3 Bucket for Backup Storage
resource "aws_s3_bucket" "backup" {
  count  = var.enable_s3_backup ? 1 : 0
  bucket = "${var.project_name}-backup-${random_string.bucket_suffix[0].result}"

  tags = var.tags
}

# Random string for bucket name
resource "random_string" "bucket_suffix" {
  count   = var.enable_s3_backup ? 1 : 0
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "backup" {
  count  = var.enable_s3_backup ? 1 : 0
  bucket = aws_s3_bucket.backup[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  count  = var.enable_s3_backup ? 1 : 0
  bucket = aws_s3_bucket.backup[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Lifecycle Policy
resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  count  = var.enable_s3_backup ? 1 : 0
  bucket = aws_s3_bucket.backup[0].id

  rule {
    id     = "backup_lifecycle"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = var.retention_days * 2
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "backup" {
  count  = var.enable_s3_backup ? 1 : 0
  bucket = aws_s3_bucket.backup[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {} 