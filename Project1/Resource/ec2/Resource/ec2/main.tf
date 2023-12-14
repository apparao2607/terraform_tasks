resource "aws_instance" "xyassss" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  key_name = "veeer"
  security_groups = ["default"]

  tags = {
    Name = "new_instance1"
  }
}
