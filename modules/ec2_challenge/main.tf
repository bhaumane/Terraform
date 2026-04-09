# Terraform EC2 Challenge Module
# 1. Create a DB server and output the private IP address
# 2. Create a Web server and ensuer it has fixed public IP address
# 3. Create a security group for the web server opening port 80 and 443 (HTTP and HTTPS)
# 4. Run the provided script on the web server.

provider "aws" {
  region = "eu-west-2"
}

# Create an EC2 DB instance
resource "aws_instance" "db_instance" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"

  tags = {
    Name = "DB Instance"
  }
}

# Create an EC2 web instance and associate it with a security group to allow web traffic and run the provided script on the web server
resource "aws_instance" "web_instance" {
    ami           = "ami-0c94855ba95c71c99"
    instance_type = "t2.micro"
    user_data = file("${path.module}/server-script.sh") # Run the provided script on the web server
    security_groups = [aws_security_group.web_traffic.name] # Associate the security group with the web server

  tags = {
    Name = "Web Instance"
  }
}

# Allocate an Elastic IP and associate it with the web EC2 instance
resource "aws_eip" "web_eip" {
    instance = aws_instance.web_instance.id  
}

# ingress variable for dynamic block
variable "ingress" {
    type = list(number)
    default = [80, 443]  
}

# egress variable for dynamic block
variable "egress" {
    type = list(number)
    default = [80, 443]  
}

# Create a security group for the web server opening port 80 and 443 (HTTP and HTTPS)

resource "aws_security_group" "web_traffic" {
    name = "Allow Web Traffic"
    description = "Security group for web server"

    # Dynamic block to create ingress rules for the security group
    dynamic "ingress" {
      iterator = port
      for_each = var.ingress
      content {
        from_port = port.value
        to_port = port.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    # Dynamic block to create egress rules for the security group
    dynamic "egress" {
      iterator = port 
      for_each = var.egress # Use the egress variable for the dynamic block
      content {
        from_port = port.value # Use the port value for the from_port and to_port
        to_port = port.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

}

output "PrivateIP" {
  value = aws_instance.db_instance.private_ip
}

output "PubicIP" {
  value = aws_instance.web_instance.public_ip
}