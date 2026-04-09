# Create an EC2 web instance and associate it with a security group to allow web traffic and run the provided script on the web server
resource "aws_instance" "web_instance" {
    ami           = "ami-0c94855ba95c71c99"
    instance_type = "t2.micro"
    user_data = file("./web/server-script.sh") # Run the provided script on the web server
    security_groups = [module.sg.sg_name] # Associate the security group with the web server

  tags = {
    Name = "Web Instance"
  }
}

output "pub_ip" {
    value = module.eip.PublicIP
}

module "eip" {
  source = "../eip"
  instance_id = aws_instance.web_instance.id
}
module "sg" {
  source = "../sg"  
}