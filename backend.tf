/*
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-jenkins"  
    key            = "terraform.tfstate" 
    region         = "us-east-1"  
    dynamodb_table = "terraform-locks"  
    encrypt        = true 
  }
}
*/
