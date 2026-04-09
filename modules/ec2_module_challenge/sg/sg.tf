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

output "sg_name" {
  value = aws_security_group.web_traffic.name
}