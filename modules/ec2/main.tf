provider "aws" {
  region = "eu-west-2"
}

# Create an EC2 instance for each environment (dev, test, prod)
resource "aws_instance" "ec2" {
  for_each = toset(["dev", "test", "prod"])
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_https.name] # Associate the security group with the EC2 instance
  tags = {
    Name = "${each.key}-instance"
  }
  
}

# Allocate an Elastic IP and associate it with the EC2 instance
resource "aws_eip" "elastic_ip" {
  instance = aws_instance.ec2["prod"].id # Associate the Elastic IP with the prod EC2 instance

}

# Output the public IP address of the Elastic IP
output "ElasticIP" {
  value = aws_eip.elastic_ip.public_ip # Output the public IP address of the Elastic IP
}

# Create a security group to allow HTTPS traffic
resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow HTTPS traffic"
  # ingress rule to allow incoming HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # egress rule to allow outgoing HTTPS traffic
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Dynamic block to create security group rules

variable "ingressrules" {
  type = list(number)
  default = [80, 443]
}

variable "engressrules" {
  type = list(number)
  default = [ 80, 443, 25, 3306, 8080 ]
}

resource "aws_security_group" "dynamic_rules" {
  name        = "dynamic_rules"
  description = "Security group with dynamic rules"

  dynamic "ingress" {
    for_each = var.ingressrules
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = var.engressrules
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

