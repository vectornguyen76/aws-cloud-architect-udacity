terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}


# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Use data sources to fetch the existing VPC and subnet
data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet" "public" {
  id = var.subnet_id
}

# Create 4 t2.micro instances named Udacity T2
resource "aws_instance" "t2_micro" {
  count         = 4
  ami           = "ami-05543abe7b00118ff"  
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.public.id

  tags = {
    Name = "Udacity T2"
  }
}

# # Create 2 m4.large instances named Udacity M4
# resource "aws_instance" "m4_large" {
#   count         = 2
#   ami           = "ami-05543abe7b00118ff"  
#   instance_type = "m4.large"
#   subnet_id     = data.aws_subnet.public.id
# 
#   tags = {
#     Name = "Udacity M4"
#   }
# }

# Outputs to display the instance IDs
output "t2_micro_instance_ids" {
  value = aws_instance.t2_micro[*].id
}

# output "m4_large_instance_ids" {
#   value = aws_instance.m4_large[*].id
# }
