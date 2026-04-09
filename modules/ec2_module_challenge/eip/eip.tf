variable "instance_id" {
  type = string  
}

# Allocate an Elastic IP and associate it with the web EC2 instance
resource "aws_eip" "web_eip" {
    instance = var.instance_id 
}

output "PublicIP" {
  value = aws_eip.web_eip.public_ip
}