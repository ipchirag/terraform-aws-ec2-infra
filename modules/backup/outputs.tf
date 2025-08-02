output "backup_vault_arn" {
  description = "ARN of the backup vault"
  value       = aws_backup_vault.main.arn
}

output "backup_vault_name" {
  description = "Name of the backup vault"
  value       = aws_backup_vault.main.name
}

output "backup_plan_arn" {
  description = "ARN of the backup plan"
  value       = aws_backup_plan.main.arn
}

output "backup_plan_id" {
  description = "ID of the backup plan"
  value       = aws_backup_plan.main.id
}

output "backup_selection_id" {
  description = "ID of the backup selection"
  value       = aws_backup_selection.main.id
}

output "backup_role_arn" {
  description = "ARN of the backup IAM role"
  value       = aws_iam_role.backup.arn
}

output "ebs_snapshot_id" {
  description = "ID of the EBS snapshot"
  value       = var.enable_ebs_snapshots ? aws_ebs_snapshot.main[0].id : null
}

output "cross_region_snapshot_id" {
  description = "ID of the cross-region snapshot"
  value       = var.enable_cross_region_backup ? aws_ebs_snapshot_copy.main[0].id : null
}

output "s3_backup_bucket_name" {
  description = "Name of the S3 backup bucket"
  value       = var.enable_s3_backup ? aws_s3_bucket.backup[0].bucket : null
}

output "s3_backup_bucket_arn" {
  description = "ARN of the S3 backup bucket"
  value       = var.enable_s3_backup ? aws_s3_bucket.backup[0].arn : null
} 