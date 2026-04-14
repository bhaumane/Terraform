provider "aws" {
    region = "eu-west-2"  
}

resource "aws_instance" "ec2" {
    ami = "ami-0c94855ba95c71c99"
    instance_type = "t2.micro"
    count = 3  
}