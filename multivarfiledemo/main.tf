# Follwing commands you can use to refer spacific var file
# terraform plan -var-file=test.tfvars   -for test environment
# terraform plan -var-file=prod.tfvars   -for prod environment

provider "aws" {
    region = "eu-west-2"  
}

variable "number_of_servers" {
    type = number
  
}

resource "aws_instance" "ec2" {
    ami = "ami-0c94855ba95c71c99"
    instance_type = "t2.micro"
    count = var.number_of_servers
}