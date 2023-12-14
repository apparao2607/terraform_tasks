provider "aws" {
  region = "us-east-1"
  profile = "pune"
}

module "ec2" {
source = "../../Resource/ec2"
  
}
