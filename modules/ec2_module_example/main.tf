provider "aws" {
    region = "eu-west-2" 
}

module "ec2module" {
  source = "./ec2"
  #ec2name = "Name from module"
}

# Output the instance ID from the EC2 module
# Access the output variable defined in the EC2 module and output it at the root level
output "module_output" {
    value = module.ec2module.instance_id  
}