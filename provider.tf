provider "aws" {    
    region = "us-east-1"
    access_key = "AKIAVRUVTGJBFDMVDRNV"
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