terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-re-backend"
    key            = "remote-module-eks"
    region         = "us-east-1"
    # dynamodb_table = "remote-lock"
    # use_lockfile = true
    encrypt = true
  }

}

provider "aws" {
  # Configuration options
}