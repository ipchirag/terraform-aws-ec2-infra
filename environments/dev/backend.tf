terraform {
  backend "s3" {
    bucket         = "terraform-state-production-ec2-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-production-ec2-dev"
    encrypt        = true
  }
} 