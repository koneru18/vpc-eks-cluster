locals {
  public_cidr_prefix  = cidrsubnet(var.vpc_cidr, 1, 0) # First half of the VPC CIDR block
  private_cidr_prefix = cidrsubnet(var.vpc_cidr, 1, 1) # Second half of the VPC CIDR block
}

resource "aws_vpc" "external_api_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name      = "${var.aws_stack_name}-vpc",
    StackName = var.aws_stack_name
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.availability_zones)
  availability_zone = element(var.availability_zones, count.index)
  cidr_block        = cidrsubnet(local.public_cidr_prefix, 3, count.index)
  vpc_id            = aws_vpc.external_api_vpc.id
  tags = {
    Name                                            = "${var.aws_stack_name}-public-subnet-${var.availability_zones[count.index]}-${count.index + 1}"
    StackName                                       = var.aws_stack_name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared",
    "kubernetes.io/role/elb"                        = "1",
  }
  # Public Subnets: 10.0.0.0/20 (AZ: us-east-1a) - 10.0.16.0/20 (AZ: us-east-1b) - 10.0.32.0/20 (AZ: us-east-1c)
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.availability_zones)
  availability_zone = element(var.availability_zones, count.index)
  cidr_block        = cidrsubnet(local.private_cidr_prefix, 3, count.index)
  vpc_id            = aws_vpc.external_api_vpc.id
  tags = {
    Name                                            = "${var.aws_stack_name}-private-subnet-${var.availability_zones[count.index]}-${count.index + 1}"
    StackName                                       = var.aws_stack_name
    "kubernetes.io/role/internal-elb"               = "1",
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared",
  }
  # Private Subnets: 10.0.128.0/20 (AZ: us-east-1a) - 10.0.144.0/20 (AZ: us-east-1b) - 10.0.160.0/20 (AZ: us-east-1c)
}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.external_api_vpc.id
  tags = {
    Name      = "${var.aws_stack_name}-igw",
    StackName = var.aws_stack_name
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eips" {
  count  = length(var.availability_zones)
  domain = "vpc"
  tags = {
    Name      = "${var.aws_stack_name}-nat-eip-${count.index + 1}",
    StackName = var.aws_stack_name
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gws" {
  count         = length(var.availability_zones)
  allocation_id = element(aws_eip.nat_eips.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)
  tags = {
    Name      = "${var.aws_stack_name}-nat-gw-${count.index + 1}",
    StackName = var.aws_stack_name
  }
  depends_on = [aws_internet_gateway.vpc_igw]
}
