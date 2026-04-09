# Terraform switch feature example
# This example demonstrates how to use a variable as a feature switch to conditionally create resources based on the environment.

provider "aws" {
    region = "eu-west-2"  
}

variable "environment" {
    type = string
}

resource "aws_instance" "ec2" {
    count = var.environment == "prod" ? 1 : 0  # Only create the instance if the environment is "prod"
    ami           = "ami-0c94855ba95c71c99"
    instance_type = "t2.micro"
    tags = {
        Name = "${var.environment}-instance"
    }
  
}
