# DATA SOURCE: Fetch available AZs automatically
data "aws_availability_zones" "available" {
  state = "available"
}

#  VPC 
resource "aws_vpc" "tobeynd_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tobeynd_vpc"
  }
}


#  PUBLIC SUBNETS 
resource "aws_subnet" "tobeynd_public_subnet_1" {
  vpc_id                  = aws_vpc.tobeynd_vpc.id
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "tobeynd_public_subnet_1"
  }
}


#  PUBLIC SUBNETS 
resource "aws_subnet" "tobeynd_public_subnet_2" {
  vpc_id                  = aws_vpc.tobeynd_vpc.id
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "tobeynd_public_subnet_2"
  }
}


