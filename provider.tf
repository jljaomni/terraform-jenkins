provider "aws" {    
    region = "us-east-1"
    access_key = "AKIAZQ3DQWDCE7MGFPPV"
    secret_key = "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"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}