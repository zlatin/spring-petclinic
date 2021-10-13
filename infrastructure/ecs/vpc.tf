

variable "VpcCIDR" {
  type    = string
  default = "10.0.0.0/16"
}

variable "PublicSubnet1CIDR" {
  type    = string
  default = "10.0.10.0/24"
}

variable "PublicSubnet2CIDR" {
  type    = string
  default = "10.0.11.0/24"
}

variable "PrivateSubnet1CIDR" {
  type    = string
  default = "10.0.20.0/24"
}

variable "PrivateSubnet2CIDR" {
  type    = string
  default = "10.0.21.0/24"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Petclinic_VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "Petclinic"
  }
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = var.PublicSubnet1CIDR
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Petclinic Public Subnet (AZ1)"
  }
}

resource "aws_subnet" "PublicSubnet2" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = var.PublicSubnet2CIDR
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Petclinic Public Subnet (AZ2)"
  }
}

resource "aws_subnet" "PrivateSubnet1" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = var.PrivateSubnet1CIDR
  map_public_ip_on_launch = false
  tags = {
    "Name" = "Petclinic Private Subnet (AZ1)"
  }
}

resource "aws_subnet" "PrivateSubnet2" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = var.PrivateSubnet2CIDR
  map_public_ip_on_launch = false
  tags = {
    "Name" = "Petclinic Private Subnet (AZ2)"
  }
}

resource "aws_eip" "NatGateway1EIP" {
  depends_on = [
    aws_internet_gateway.igw
  ]
  vpc = true
}

resource "aws_eip" "NatGateway2EIP" {
  depends_on = [
    aws_internet_gateway.igw
  ]
  vpc = true
}

resource "aws_nat_gateway" "NatGateway1" {
  allocation_id = aws_eip.NatGateway1EIP.id
  subnet_id     = aws_subnet.PublicSubnet1.id
}

resource "aws_nat_gateway" "NatGateway2" {
  allocation_id = aws_eip.NatGateway2EIP.id
  subnet_id     = aws_subnet.PublicSubnet2.id
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Petclinic Public Routes"
  }
}

resource "aws_route" "DefaultPublicRoute" {
  route_table_id         = aws_route_table.PublicRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "PublicSubnet1RouteTableAssociation" {
  route_table_id = aws_route_table.PublicRouteTable.id
  subnet_id      = aws_subnet.PublicSubnet1.id
}

resource "aws_route_table_association" "PublicSubnet2RouteTableAssociation" {
  route_table_id = aws_route_table.PublicRouteTable.id
  subnet_id      = aws_subnet.PublicSubnet2.id
}

resource "aws_route_table" "PrivateRouteTable1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Petclinic Private Routes (AZ1)"
  }
}

resource "aws_route" "DefaultPrivateRoute1" {
  route_table_id         = aws_route_table.PrivateRouteTable1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NatGateway1.id
}

resource "aws_route_table_association" "PrivateSubnet1RouteTableAssociation" {
  route_table_id = aws_route_table.PrivateRouteTable1.id
  subnet_id      = aws_subnet.PrivateSubnet1.id
}

resource "aws_route_table" "PrivateRouteTable2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Petclinic Private Routes (AZ2)"
  }
}

resource "aws_route" "DefaultPrivateRoute2" {
  route_table_id         = aws_route_table.PrivateRouteTable2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NatGateway2.id
}

resource "aws_route_table_association" "PrivateSubnet2RouteTableAssociation" {
  route_table_id = aws_route_table.PrivateRouteTable2.id
  subnet_id      = aws_subnet.PrivateSubnet2.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}





