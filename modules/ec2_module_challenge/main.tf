# Terraform EC2 Challenge Module
# 1. Create a DB server and output the private IP address
# 2. Create a Web server and ensuer it has fixed public IP address
# 3. Create a security group for the web server opening port 80 and 443 (HTTP and HTTPS)
# 4. Run the provided script on the web server.

provider "aws" {
  region = "eu-west-2"
}

module "db" {
  source = "./db"
}

module "web" {
    source = "./web"  
}


output "PrivateIP" {
    value = module.db.PrivateIP  
}

output "PubicIP" {
  value = module.web.pub_ip
}

