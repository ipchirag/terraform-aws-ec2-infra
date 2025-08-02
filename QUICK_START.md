# Quick Start Guide

This guide will help you quickly deploy the production-ready AWS EC2 infrastructure using Terraform.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

### Required Software
- **Terraform** >= 1.0 ([Install Guide](https://developer.hashicorp.com/terraform/downloads))
- **AWS CLI** >= 2.0 ([Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- **jq** ([Install Guide](https://stedolan.github.io/jq/download/))

### AWS Configuration
1. **Configure AWS CLI**:
   ```bash
   aws configure
   ```
   Enter your AWS Access Key ID, Secret Access Key, default region (us-west-2), and output format (json).

2. **Verify AWS Access**:
   ```bash
   aws sts get-caller-identity
   ```

## Quick Deployment

### Step 1: Setup Backend Infrastructure

First, create the S3 buckets and DynamoDB tables for remote state management:

```bash
# Make scripts executable (if not already done)
chmod +x scripts/*.sh

# Setup backend infrastructure
./scripts/setup-backend.sh
```

This script will create:
- S3 buckets for Terraform state storage
- DynamoDB tables for state locking
- Proper encryption and access controls

### Step 2: Deploy Development Environment

Deploy the development environment to test the infrastructure:

```bash
# Initialize and deploy development environment
./scripts/deploy.sh -i dev
./scripts/deploy.sh -a dev
```

This will:
- Initialize Terraform with the S3 backend
- Plan and apply the infrastructure
- Show you the outputs and access information

### Step 3: Verify Deployment

Check that your infrastructure is working:

```bash
# Get the load balancer URL
./scripts/deploy.sh dev | grep "Application URL"

# Test the health endpoint
curl http://<load-balancer-dns>/health
```

## Environment-Specific Deployments

### Development Environment
```bash
./scripts/deploy.sh -a dev
```
- **Purpose**: Development and testing
- **Cost**: ~$50-100/month
- **Features**: Spot instances, basic monitoring, cost optimization

### Staging Environment
```bash
./scripts/deploy.sh -a staging
```
- **Purpose**: Pre-production testing
- **Cost**: ~$200-400/month
- **Features**: Full monitoring, backup, corporate security

### Production Environment
```bash
./scripts/deploy.sh -a prod
```
- **Purpose**: Live production workload
- **Cost**: ~$500-1000+/month
- **Features**: High availability, comprehensive monitoring, strict security

## Infrastructure Components

### What Gets Deployed

1. **Networking**:
   - VPC with public/private subnets
   - Internet Gateway and NAT Gateway
   - VPC Endpoints for AWS services

2. **Security**:
   - Security groups with least privilege
   - IAM roles and policies
   - KMS encryption keys

3. **Compute**:
   - EC2 instances with Auto Scaling Groups
   - Application Load Balancer
   - Launch templates with user data

4. **Monitoring**:
   - CloudWatch dashboards and alarms
   - SNS notifications
   - Centralized logging

5. **Backup** (Production/Staging):
   - AWS Backup vault and plans
   - Automated EBS snapshots
   - Cross-region backup (optional)

## Accessing Your Infrastructure

### Load Balancer Access
```bash
# Get the load balancer URL
terraform output -raw alb_dns_name

# Access your application
curl http://<load-balancer-dns>
```

### SSH Access (if enabled)
```bash
# Get instance information
aws ec2 describe-instances --filters "Name=tag:Name,Values=*instance*" --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,State.Name]' --output table

# SSH to instance (replace with your key and instance IP)
ssh -i ~/.ssh/<key-name>.pem ec2-user@<instance-ip>
```

### CloudWatch Dashboard
```bash
# Get dashboard URL
terraform output -raw cloudwatch_dashboard_name
```
Visit the AWS Console → CloudWatch → Dashboards to view your metrics.

## Common Operations

### View Infrastructure Status
```bash
# Show current state
./scripts/deploy.sh -v <environment>

# Show outputs
cd environments/<environment>
terraform output
cd ../..
```

### Update Infrastructure
```bash
# Plan changes
./scripts/deploy.sh -p <environment>

# Apply changes
./scripts/deploy.sh -a <environment>
```

### Scale Infrastructure
```bash
# Update instance count in terraform.tfvars
# Then apply changes
./scripts/deploy.sh -a <environment>
```

### Destroy Infrastructure
```bash
# Destroy environment (use with caution!)
./scripts/deploy.sh -d <environment> -f
```

## Troubleshooting

### Common Issues

1. **Backend Setup Fails**:
   ```bash
   # Check AWS credentials
   aws sts get-caller-identity
   
   # Check S3 bucket permissions
   aws s3 ls s3://terraform-state-production-ec2-dev
   ```

2. **Terraform Init Fails**:
   ```bash
   # Clean up and retry
   rm -rf environments/*/.terraform
   ./scripts/deploy.sh -i <environment>
   ```

3. **Instance Launch Fails**:
   ```bash
   # Check CloudWatch logs
   aws logs describe-log-groups --log-group-name-prefix "/aws/ec2/production-ec2"
   
   # Check Auto Scaling Group events
   aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names <asg-name>
   ```

4. **Load Balancer Health Check Fails**:
   ```bash
   # Check target group health
   aws elbv2 describe-target-health --target-group-arn <target-group-arn>
   
   # Check instance connectivity
   aws ec2 describe-instances --instance-ids <instance-id>
   ```

### Getting Help

1. **Check Terraform Documentation**: [https://www.terraform.io/docs](https://www.terraform.io/docs)
2. **Review AWS Documentation**: [https://docs.aws.amazon.com/](https://docs.aws.amazon.com/)
3. **Check CloudWatch Logs**: Look for application and system logs
4. **Review Security Groups**: Ensure proper port access

## Cost Optimization

### Development Environment
- Uses spot instances for cost savings
- Scheduled scaling down during off-hours
- Minimal backup and monitoring

### Production Environment
- On-demand instances for reliability
- Comprehensive backup and monitoring
- Multi-AZ deployment for high availability

### Cost Monitoring
```bash
# Set up AWS Cost Explorer
# Monitor costs in AWS Console → Billing → Cost Explorer
```

## Security Best Practices

### Implemented Security Features
- All instances in private subnets
- Security groups with least privilege
- KMS encryption for all data
- IAM roles with minimal permissions
- VPC endpoints for private AWS access

### Additional Recommendations
1. **Enable AWS Config** for compliance monitoring
2. **Set up AWS GuardDuty** for threat detection
3. **Use AWS Secrets Manager** for sensitive data
4. **Implement AWS WAF** for web application protection
5. **Enable AWS CloudTrail** for API logging

## Next Steps

### Customization
1. **Modify terraform.tfvars** for environment-specific settings
2. **Add custom modules** for application-specific resources
3. **Integrate with CI/CD** for automated deployments
4. **Set up monitoring** for your specific application metrics

### Advanced Features
1. **Multi-region deployment** for disaster recovery
2. **Container orchestration** with ECS/EKS
3. **Serverless integration** with Lambda
4. **Advanced monitoring** with APM tools

### Production Readiness
1. **Security review** and penetration testing
2. **Performance testing** and load testing
3. **Disaster recovery** testing
4. **Compliance audit** (if required)

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review the architecture documentation in `docs/ARCHITECTURE.md`
3. Check Terraform and AWS documentation
4. Review CloudWatch logs for detailed error information

---

**Note**: This infrastructure is designed for production use but should be reviewed and customized for your specific requirements before deploying to production environments. 