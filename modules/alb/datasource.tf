data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical's AWS Account ID
}

data "aws_vpc" "togetvpc_id" {
  filter {
    name   = "cidr-block"
    values = ["10.2.0.0/16"]
  }
}

# Data Source to Fetch All Subnets in the VPC:
data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = ["vpc-0e085fee9299e3036"]  # Replace with your VPC ID
  }
}
 
# Data Source to Get Details of Each Subnet:
# Iterates over all subnet IDs fetched by aws_subnets to get detailed information about each subnet.
# Uses count to iterate over each subnet ID.

data "aws_subnet" "subnet_details" {
  count = length(data.aws_subnets.vpc_subnets.ids)
  id    = data.aws_subnets.vpc_subnets.ids[count.index]
}

# Local Value to Filter Public Subnets:
# Creates a list (public_subnet_ids) containing only the IDs of subnets
# where map_public_ip_on_launch is true, indicating that the subnet is public.

locals {
  public_subnet_ids = [
    for subnet in data.aws_subnet.subnet_details :
    subnet.id if subnet.map_public_ip_on_launch
  ]
}


