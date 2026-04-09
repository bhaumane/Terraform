variable "ec2name" {
    type = string
    default = "Default EC2 Name"  
}

resource "aws_instance" "ec2" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  tags = {
    Name = var.ec2name
  }
}