terraform {
  backend "s3" {
    bucket         = "terraform-state-production-ec2-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-production-ec2-prod"
    encrypt        = true
  }
} 