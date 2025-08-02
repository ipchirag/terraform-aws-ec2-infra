#!/bin/bash

# Setup script for Terraform backend infrastructure
# This script creates the necessary S3 buckets and DynamoDB tables for remote state management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
}

# Function to check if AWS credentials are configured
check_aws_credentials() {
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured. Please run 'aws configure' first."
        exit 1
    fi
}

# Function to create S3 bucket
create_s3_bucket() {
    local bucket_name=$1
    local region=$2
    
    print_status "Creating S3 bucket: $bucket_name"
    
    if aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
        print_warning "Bucket $bucket_name already exists"
    else
        aws s3api create-bucket \
            --bucket "$bucket_name" \
            --region "$region" \
            --create-bucket-configuration LocationConstraint="$region"
        
        # Enable versioning
        aws s3api put-bucket-versioning \
            --bucket "$bucket_name" \
            --versioning-configuration Status=Enabled
        
        # Enable server-side encryption
        aws s3api put-bucket-encryption \
            --bucket "$bucket_name" \
            --server-side-encryption-configuration '{
                "Rules": [
                    {
                        "ApplyServerSideEncryptionByDefault": {
                            "SSEAlgorithm": "AES256"
                        }
                    }
                ]
            }'
        
        # Block public access
        aws s3api put-public-access-block \
            --bucket "$bucket_name" \
            --public-access-block-configuration \
                BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
        
        print_status "S3 bucket $bucket_name created successfully"
    fi
}

# Function to create DynamoDB table
create_dynamodb_table() {
    local table_name=$1
    local region=$2
    
    print_status "Creating DynamoDB table: $table_name"
    
    if aws dynamodb describe-table --table-name "$table_name" --region "$region" &>/dev/null; then
        print_warning "Table $table_name already exists"
    else
        aws dynamodb create-table \
            --table-name "$table_name" \
            --attribute-definitions AttributeName=LockID,AttributeType=S \
            --key-schema AttributeName=LockID,KeyType=HASH \
            --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
            --region "$region"
        
        # Wait for table to be active
        aws dynamodb wait table-exists --table-name "$table_name" --region "$region"
        
        print_status "DynamoDB table $table_name created successfully"
    fi
}

# Main script
main() {
    print_status "Starting Terraform backend setup..."
    
    # Check prerequisites
    check_aws_cli
    check_aws_credentials
    
    # Get AWS account ID
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    REGION="us-west-2"
    
    print_status "AWS Account ID: $ACCOUNT_ID"
    print_status "Region: $REGION"
    
    # Create S3 buckets for each environment
    ENVIRONMENTS=("dev" "staging" "prod")
    
    for env in "${ENVIRONMENTS[@]}"; do
        print_status "Setting up backend for $env environment..."
        
        # Create S3 bucket
        BUCKET_NAME="terraform-state-production-ec2-$env"
        create_s3_bucket "$BUCKET_NAME" "$REGION"
        
        # Create DynamoDB table
        TABLE_NAME="terraform-locks-production-ec2-$env"
        create_dynamodb_table "$TABLE_NAME" "$REGION"
        
        print_status "$env environment backend setup completed"
        echo
    done
    
    print_status "All backend infrastructure created successfully!"
    print_status "You can now run 'terraform init' in each environment directory."
}

# Run main function
main "$@" 