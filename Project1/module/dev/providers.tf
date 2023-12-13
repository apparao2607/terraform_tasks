provider "aws" {
  region = "us-east-1"
  access_key = "AKIA2FHJLDIYJENIEP2B"
  secret_key = "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"
}

module "ec2" {
source = "../../Resource/ec2"
  
}