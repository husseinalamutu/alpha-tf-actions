terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4.0"
    }
  }

  backend "s3" {
    bucket = "module-bucket-alpha"
    key    = "tf-statefile/terraform.tfstate"
    region = "us-east-1"
  }

  required_version = ">=1.1.0"
}

provider "aws" {
  region = "us-east-1"
}