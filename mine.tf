provider "aws" {
  region = "us-east-1"
  access_key = "AKIA2FHJLDIYPF4QGQ77"
  secret_key = "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"
}
resource "aws_s3_bucket" "miny789523" {
  bucket = "railway789456123"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
