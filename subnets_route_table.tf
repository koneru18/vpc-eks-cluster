
# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.external_api_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }
  tags = {
    Name      = "${var.aws_stack_name}-public-rt",
    StackName = var.aws_stack_name
  }
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.external_api_vpc.id
  tags = {
    Name      = "${var.aws_stack_name}-private-rt",
    StackName = var.aws_stack_name
  }
  depends_on = [aws_nat_gateway.nat_gws]
}

# Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "public_rta" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

# Associate Private Route Table with Private Subnets
resource "aws_route_table_association" "private_rta" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}
