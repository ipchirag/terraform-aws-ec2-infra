terraform {
  backend "s3" {
    bucket         = "terraform-state-production-ec2-staging"
    key            = "staging/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-production-ec2-staging"
    encrypt        = true
  }
} 