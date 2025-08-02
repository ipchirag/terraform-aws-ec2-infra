# Infrastructure Architecture Documentation

## Overview

This document describes the architecture of the production-ready AWS EC2 infrastructure built with Terraform. The infrastructure follows a modular design pattern with separate environments for development, staging, and production.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS Cloud                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐ │
│  │   Route 53      │    │   CloudFront    │    │   WAF       │ │
│  │   (DNS)         │    │   (CDN)         │    │   (Security)│ │
│  └─────────────────┘    └─────────────────┘    └─────────────┘ │
│           │                       │                     │       │
│           └───────────────────────┼─────────────────────┘       │
│                                   │                             │
│  ┌─────────────────────────────────┼─────────────────────────────┐ │
│  │                    Application Load Balancer                  │ │
│  │                         (ALB)                                 │ │
│  └─────────────────────────────────┼─────────────────────────────┘ │
│                                   │                             │
│  ┌─────────────────────────────────┼─────────────────────────────┐ │
│  │                            VPC                                │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐ │ │
│  │  │   Public        │    │   Private       │    │   Database  │ │ │
│  │  │   Subnets       │    │   Subnets       │    │   Subnets   │ │ │
│  │  │                 │    │                 │    │             │ │ │
│  │  │  ┌───────────┐  │    │  ┌───────────┐  │    │ ┌─────────┐ │ │ │
│  │  │  │   NAT     │  │    │  │   EC2     │  │    │ │   RDS   │ │ │ │
│  │  │  │ Gateway   │  │    │  │ Instances │  │    │ │   DB    │ │ │ │
│  │  │  └───────────┘  │    │  └───────────┘  │    │ └─────────┘ │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐ │
│  │   CloudWatch    │    │   SNS           │    │   S3        │ │
│  │   (Monitoring)  │    │   (Alerts)      │    │   (Logs)    │ │
│  └─────────────────┘    └─────────────────┘    └─────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Components

### 1. Networking Layer

#### VPC (Virtual Private Cloud)
- **CIDR Block**: Configurable per environment (10.0.0.0/16 for dev, 10.1.0.0/16 for staging, 10.2.0.0/16 for prod)
- **DNS Support**: Enabled for both hostnames and resolution
- **Features**: 
  - Multi-AZ deployment across 2-3 availability zones
  - Public and private subnets
  - Database subnets for RDS instances

#### Subnets
- **Public Subnets**: Host NAT Gateway and Application Load Balancer
- **Private Subnets**: Host EC2 instances in Auto Scaling Groups
- **Database Subnets**: Isolated subnets for database instances

#### Internet Gateway & NAT Gateway
- **Internet Gateway**: Provides internet access for public subnets
- **NAT Gateway**: Enables private instances to access internet for updates and external services

#### VPC Endpoints
- **S3 Endpoint**: Private access to S3 without internet gateway
- **EC2 Endpoint**: Private access to EC2 API
- **SSM Endpoints**: Private access to Systems Manager services

### 2. Security Layer

#### Security Groups
- **ALB Security Group**: Allows HTTP/HTTPS traffic from internet
- **EC2 Security Group**: Allows application traffic from ALB and SSH from authorized IPs
- **RDS Security Group**: Allows database traffic from EC2 instances only
- **VPC Endpoints Security Group**: Allows HTTPS traffic from EC2 instances

#### IAM Roles & Policies
- **EC2 Instance Role**: Minimal permissions for CloudWatch, S3, and SSM
- **CloudWatch Agent Policy**: Permissions for metrics and logs
- **SSM Policy**: Permissions for Systems Manager access

#### KMS Encryption
- **EBS Encryption**: All EBS volumes encrypted with customer-managed KMS key
- **S3 Encryption**: Server-side encryption for all S3 buckets
- **Key Rotation**: Automatic key rotation enabled

### 3. Compute Layer

#### Launch Template
- **AMI**: Latest Amazon Linux 2 or Ubuntu 22.04
- **Instance Type**: Configurable per environment (t3.small for dev, t3.medium for staging, t3.large for prod)
- **User Data**: Automated instance initialization with security hardening
- **Metadata Options**: IMDSv2 enabled with hop limit of 1

#### Auto Scaling Group
- **Scaling Policies**: CPU-based scaling with configurable thresholds
- **Health Checks**: ELB health checks with configurable grace period
- **Scheduled Actions**: Optional cost optimization for non-production environments

#### Application Load Balancer
- **Type**: Application Load Balancer (ALB)
- **Health Checks**: Configurable path and port
- **Target Groups**: Instance targets with health check configuration
- **Listeners**: HTTP (80) and HTTPS (443) if certificate provided

### 4. Monitoring Layer

#### CloudWatch
- **Dashboards**: Custom dashboards for infrastructure metrics
- **Log Groups**: Centralized logging for system, security, and application logs
- **Metrics**: Custom metrics collection via CloudWatch Agent
- **Alarms**: Multi-threshold alarms for CPU, memory, disk, and application metrics

#### SNS Notifications
- **Topics**: Centralized notification topics per environment
- **Subscriptions**: Email notifications for critical alerts
- **Auto Scaling Events**: Notifications for scaling activities

#### CloudWatch Events
- **Auto Scaling Events**: Capture and notify on scaling activities
- **Custom Events**: Extensible for application-specific events

### 5. Backup & Recovery

#### AWS Backup
- **Vault**: Encrypted backup vault per environment
- **Plans**: Daily, weekly, and monthly backup schedules
- **Selection**: Tag-based resource selection
- **Retention**: Configurable retention periods per environment

#### EBS Snapshots
- **Automated Snapshots**: Daily snapshots with configurable retention
- **Cross-Region**: Optional cross-region backup for disaster recovery
- **Encryption**: All snapshots encrypted with KMS

## Environment-Specific Configurations

### Development Environment
- **Instance Type**: t3.small
- **Instance Count**: 1-3
- **Spot Instances**: Enabled for cost optimization
- **Backup**: Disabled to reduce costs
- **Monitoring**: Basic monitoring enabled
- **Security**: More permissive for development

### Staging Environment
- **Instance Type**: t3.medium
- **Instance Count**: 2-4
- **Spot Instances**: Disabled for stability
- **Backup**: Enabled with 14-day retention
- **Monitoring**: Full monitoring with SNS notifications
- **Security**: Corporate network restrictions

### Production Environment
- **Instance Type**: t3.large
- **Instance Count**: 3-10
- **Spot Instances**: Disabled for reliability
- **Backup**: Full backup with 30-day retention
- **Monitoring**: Comprehensive monitoring with on-call notifications
- **Security**: Strict security with SSH disabled

## Security Features

### Network Security
- **Private Subnets**: All application instances in private subnets
- **Security Groups**: Least privilege access with specific port allowances
- **NACLs**: Network Access Control Lists for additional security
- **VPC Endpoints**: Private access to AWS services

### Access Control
- **IAM Roles**: Instance profiles with minimal required permissions
- **SSH Access**: Configurable per environment (disabled in production)
- **Key Management**: KMS encryption for all sensitive data
- **Secrets Management**: Integration with AWS Secrets Manager

### Compliance
- **Encryption**: All data encrypted at rest and in transit
- **Logging**: Comprehensive audit logging
- **Monitoring**: Real-time security monitoring
- **Backup**: Automated backup and recovery procedures

## Cost Optimization

### Instance Management
- **Spot Instances**: Used in development for cost savings
- **Auto Scaling**: Dynamic scaling based on demand
- **Scheduled Actions**: Scale down during off-hours in non-production

### Storage Optimization
- **EBS Volume Types**: GP3 for cost-effective performance
- **S3 Lifecycle**: Automatic transition to cheaper storage classes
- **Backup Retention**: Environment-specific retention policies

### Monitoring Costs
- **Log Retention**: Configurable retention periods
- **Custom Metrics**: Selective metric collection
- **Alarm Optimization**: Focused on critical metrics only

## Disaster Recovery

### Backup Strategy
- **Daily Backups**: Automated daily backups of all critical resources
- **Cross-Region**: Optional cross-region backup for critical environments
- **Point-in-Time Recovery**: RDS point-in-time recovery capabilities

### Recovery Procedures
- **RTO/RPO**: 4-hour RTO, 1-hour RPO for production
- **Testing**: Regular disaster recovery testing
- **Documentation**: Detailed recovery runbooks

## Monitoring & Alerting

### Key Metrics
- **Infrastructure**: CPU, memory, disk, network utilization
- **Application**: Response time, error rates, throughput
- **Business**: User activity, transaction volume

### Alerting Strategy
- **Critical**: Immediate notification for service outages
- **Warning**: Notification for performance degradation
- **Info**: Daily summary reports

## Deployment Process

### CI/CD Integration
- **Terraform Plan**: Automated plan generation
- **Approval Gates**: Manual approval for production changes
- **Rollback**: Automated rollback capabilities

### Environment Promotion
- **Dev → Staging**: Automated promotion with testing
- **Staging → Prod**: Manual approval with comprehensive testing
- **Blue-Green**: Optional blue-green deployment for zero downtime

## Maintenance & Operations

### Regular Maintenance
- **AMI Updates**: Monthly AMI updates for security patches
- **Terraform Updates**: Regular Terraform version updates
- **Security Scans**: Automated security vulnerability scanning

### Operational Procedures
- **Incident Response**: Documented incident response procedures
- **Change Management**: Formal change management process
- **Capacity Planning**: Regular capacity planning and optimization

## Future Enhancements

### Planned Improvements
- **Multi-Region**: Active-active multi-region deployment
- **Containerization**: Migration to ECS/EKS for better resource utilization
- **Serverless**: Integration with Lambda for event-driven processing
- **Advanced Monitoring**: APM and distributed tracing integration

### Scalability Considerations
- **Horizontal Scaling**: Auto Scaling Group expansion capabilities
- **Vertical Scaling**: Instance type upgrade procedures
- **Database Scaling**: Read replicas and sharding strategies 