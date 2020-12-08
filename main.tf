provider "aws" {
  profile = var.aws_profile
  region = var.aws_region
}

terraform {
  backend "s3" {
  }

  required_providers {
    aws = "~> 3.0"
  }
}

