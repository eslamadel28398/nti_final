# Configure the AWS Provider
provider "aws" {
  region = var.region # Change to your desired region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}


