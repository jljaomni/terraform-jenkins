resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket-jenkins" 
  versioning {
    enabled = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Dev"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Locks Table"
    Environment = "Dev"
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-jenkins"  
    key            = "terraform.tfstate" 
    region         = "us-east-1"  
    dynamodb_table = "terraform-locks"  
    encrypt        = true 
  }
}
