terraform {
  backend "s3" {
    bucket = "challange-1"
    key = "main"
    region = "us-east-1"
    dynamodb_table = "challange-1"
  }
}