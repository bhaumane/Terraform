provider "aws" {
  region = "eu-west-2"
}

module "ec2" {
    source = "./ec2"
    for_each = toset(["dev", "test", "prod"])
    }

resource "aws_instance" "ec2" {
  for_each = toset(["dev", "test", "prod"])
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  tags = {
    Name = "${each.key}-instance"
  }
  
}