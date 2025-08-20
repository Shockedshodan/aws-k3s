provider "aws" {
  region  = "us-west-2"
  profile = "tf-admin"
}

terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9.0"
    }
  }
  # backend "s3" {
  #   bucket = "epta-tf-state-bucket"
  #   key    = "infra/terraform.tfstate"
  #   region = "us-west-2"
  #   dynamodb_table = "epta-tf-state-lock"
  #   encrypt = true
  #   profile = "tf-admin"
  # }
}
