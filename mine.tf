provider "aws" {
  region = "us-east-1"
  profile = "pune"
}
resource "aws_s3_bucket" "miny789523" {
  bucket = "railway789456123"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
