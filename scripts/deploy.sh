#!/bin/bash

# Deployment script for Terraform infrastructure
# This script automates the deployment process for different environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}[HEADER]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] ENVIRONMENT"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -p, --plan          Only run terraform plan"
    echo "  -a, --apply         Run terraform plan and apply"
    echo "  -d, --destroy       Run terraform destroy"
    echo "  -f, --force         Skip confirmation prompts"
    echo "  -v, --validate      Run terraform validate"
    echo "  -i, --init          Run terraform init"
    echo ""
    echo "Environments:"
    echo "  dev                 Development environment"
    echo "  staging             Staging environment"
    echo "  prod                Production environment"
    echo ""
    echo "Examples:"
    echo "  $0 -p dev           Plan development environment"
    echo "  $0 -a staging       Apply staging environment"
    echo "  $0 -d prod -f       Destroy production environment (force)"
}

# Function to check if environment is valid
validate_environment() {
    local env=$1
    case $env in
        dev|staging|prod)
            return 0
            ;;
        *)
            print_error "Invalid environment: $env"
            print_error "Valid environments: dev, staging, prod"
            return 1
            ;;
    esac
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check Terraform version
    TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_status "Terraform version: $TF_VERSION"
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed. Please install it first."
        exit 1
    fi
    
    print_status "All prerequisites met"
}

# Function to run terraform init
run_init() {
    local env=$1
    print_status "Running terraform init for $env environment..."
    
    cd "environments/$env"
    terraform init
    cd ../..
}

# Function to run terraform validate
run_validate() {
    local env=$1
    print_status "Running terraform validate for $env environment..."
    
    cd "environments/$env"
    terraform validate
    cd ../..
}

# Function to run terraform plan
run_plan() {
    local env=$1
    print_status "Running terraform plan for $env environment..."
    
    cd "environments/$env"
    terraform plan -out=tfplan
    cd ../..
}

# Function to run terraform apply
run_apply() {
    local env=$1
    local force=$2
    
    print_status "Running terraform apply for $env environment..."
    
    if [ "$env" = "prod" ] && [ "$force" != "true" ]; then
        print_warning "You are about to apply changes to PRODUCTION environment!"
        read -p "Are you sure you want to continue? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            print_error "Deployment cancelled"
            exit 1
        fi
    fi
    
    cd "environments/$env"
    
    if [ -f "tfplan" ]; then
        terraform apply tfplan
        rm tfplan
    else
        terraform apply -auto-approve
    fi
    
    cd ../..
}

# Function to run terraform destroy
run_destroy() {
    local env=$1
    local force=$2
    
    print_warning "You are about to DESTROY the $env environment!"
    print_warning "This action cannot be undone!"
    
    if [ "$force" != "true" ]; then
        read -p "Are you absolutely sure? Type 'destroy' to confirm: " confirm
        if [ "$confirm" != "destroy" ]; then
            print_error "Destroy cancelled"
            exit 1
        fi
    fi
    
    print_status "Running terraform destroy for $env environment..."
    
    cd "environments/$env"
    terraform destroy -auto-approve
    cd ../..
}

# Function to show outputs
show_outputs() {
    local env=$1
    print_status "Showing outputs for $env environment..."
    
    cd "environments/$env"
    terraform output
    cd ../..
}

# Function to show infrastructure summary
show_summary() {
    local env=$1
    print_header "Infrastructure Summary for $env environment"
    
    cd "environments/$env"
    
    # Get key outputs
    VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || echo "N/A")
    ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "N/A")
    ASG_NAME=$(terraform output -raw autoscaling_group_name 2>/dev/null || echo "N/A")
    
    echo "VPC ID: $VPC_ID"
    echo "Load Balancer DNS: $ALB_DNS"
    echo "Auto Scaling Group: $ASG_NAME"
    
    if [ "$ALB_DNS" != "N/A" ]; then
        echo "Application URL: http://$ALB_DNS"
        echo "Health Check URL: http://$ALB_DNS/health"
    fi
    
    cd ../..
}

# Main script
main() {
    local action=""
    local environment=""
    local force=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -p|--plan)
                action="plan"
                shift
                ;;
            -a|--apply)
                action="apply"
                shift
                ;;
            -d|--destroy)
                action="destroy"
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -v|--validate)
                action="validate"
                shift
                ;;
            -i|--init)
                action="init"
                shift
                ;;
            dev|staging|prod)
                environment=$1
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check if environment is provided
    if [ -z "$environment" ]; then
        print_error "Environment is required"
        show_usage
        exit 1
    fi
    
    # Validate environment
    validate_environment "$environment"
    
    # Check prerequisites
    check_prerequisites
    
    # Check if environment directory exists
    if [ ! -d "environments/$environment" ]; then
        print_error "Environment directory 'environments/$environment' does not exist"
        exit 1
    fi
    
    # Execute action
    case $action in
        init)
            run_init "$environment"
            ;;
        validate)
            run_validate "$environment"
            ;;
        plan)
            run_plan "$environment"
            ;;
        apply)
            run_apply "$environment" "$force"
            show_outputs "$environment"
            show_summary "$environment"
            ;;
        destroy)
            run_destroy "$environment" "$force"
            ;;
        "")
            print_error "No action specified"
            show_usage
            exit 1
            ;;
    esac
    
    print_status "Operation completed successfully"
}

# Run main function
main "$@" 