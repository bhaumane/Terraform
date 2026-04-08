# Terroform variables
# This file contains  the variables used in the Terraform configuration. 
# It defines the input parameters that can be customized when deploying the infrastructure. Each variable includes a description and a default value where applicable.

provider "aws" {
    region = "us-west-2"  
}

# String variable example
variable "vpcname" {
  description = "The name of the VPC to be deployed."
  type        = string
  default     = "my-terraform-vpc"
}

# Number variable example
variable "instance_count" {
  description = "The number of instances to create."
  type        = number
  default     = 3
}

# Boolean variable example
variable "enable_monitoring" {
  description = "Whether to enable monitoring for the instances."
  type        = bool
  default     = true
}

# List variable example
variable "mylist" {
  description = "A list of instance types to be used for the deployment."
  type        = list(string)
  default     = ["t2.micro", "t2.small", "t2.medium"]
}

# Map variable example
variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
  default     = {
    Environment = "dev"
    Owner       = "team-terraform"
  }
}

variable "vpc_cidr" {
    description = "VPC cidr block"
    type = string
    default = "10.0.0.0/16"
}

# VPC string variable example
resource "aws_vpc" "myvpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = var.vpcname
    }
}

# VPC list variable example
resource "aws_vpc" "myvpc" {
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = var.mylist[0]  # Using the first instance type as a tag for demonstration
    }
}

# VPC map variable example
resource "aws_vpc" "myvpc" {
    cidr_block = "10.0.0.0/16"
    tags = var.tags["Environment"]  # Using the "Environment" tag from the map variable
}

# VPC Input variable example
variable "inputname" {
    description = "Input variable for VPC name"
    type = string
    default = "my-input-vpc"  
}


resource "aws_vpc" "myvpc" {
    cidr_block = var.vpc_cidr

    tags = {
        Name = var.inputname  # Using the input variable for the VPC name
    }

}

# VPC output variable example
output "vpc_id" {
    description = "The ID of the created VPC"
    value       = aws_vpc.myvpc.id
}

# Tuple variable example
variable "mytuple" {
  description = "A tuple variable example"
  type        = tuple([string, number, bool])
  default     = ["example", 42, true]
}

# Object variable example
variable "myobject" {
    description = "An object variable example"
    type        = object({
        name    = string
        age     = number
        is_active = bool
    })
    default     = {
        name      = "John Doe"
        age       = 30
        is_active = true
    }
}
