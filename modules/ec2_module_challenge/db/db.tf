# Create an EC2 DB instance
resource "aws_instance" "db_instance" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"

  tags = {
    Name = "DB Instance"
  }
}

output "PrivateIP" {
  value = aws_instance.db_instance.private_ip
}