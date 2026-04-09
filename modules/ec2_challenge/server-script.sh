#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "Hello from the EC2 Challenge Web Server!" > | sudo tee /var/www/html/index.html