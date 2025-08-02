output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "ec2_iam_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2.arn
}

output "ec2_iam_role_name" {
  description = "Name of the EC2 IAM role"
  value       = aws_iam_role.ec2.name
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2.arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2.name
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = var.create_key_pair ? aws_key_pair.main[0].key_name : null
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = var.enable_kms ? aws_kms_key.main[0].arn : null
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = var.enable_kms ? aws_kms_key.main[0].key_id : null
}

output "kms_alias_arn" {
  description = "ARN of the KMS alias"
  value       = var.enable_kms ? aws_kms_alias.main[0].arn : null
} 