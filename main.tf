
# Create the VPC
resource "aws_vpc" "my_vpc" {

  count = var.create_vpc ? 1 : 0

  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support = var.enable_dns_support
  tags = var.tags
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  count  = var.create_internet_gateway ? 1 : 0
  
  vpc_id = aws_vpc.my_vpc.id
  tags = var.tags
}

# Create public subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidr_blocks)
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  vpc_id                  = aws_vpc.main.id
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = merge(var.tags, { Name = "public-${count.index + 1}" })
}

# Create route tables for public subnets
resource "aws_route_table" "public_route_table" {
  count  = length(aws_subnet.public_subnet)
  vpc_id = aws_vpc.my_vpc.id
  tags   = merge(var.tags, { Name = "public-route-table-${count.index + 1}" })
}

# Create a default route in the public route tables through the Internet Gateway
resource "aws_route" "public_default_route" {
  count               = length(aws_subnet.public_subnet)
  route_table_id      = aws_route_table.public_route_table[count.index].id
  destination_cidr_block = var.public_route_destination
  gateway_id          = aws_internet_gateway.my_igw.id
}

# Associate public subnets with the route table
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index].id
}

# Create private subnets
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidr_blocks)
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  vpc_id            = aws_vpc.main.id
  availability_zone       = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)
  tags = merge(var.tags, { Name = "private-${count.index  + 1}" })
}

# Create a NAT Gateway for each private subnet
resource "aws_nat_gateway" "nat" {
  count         = length(aws_subnet.private)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.private[count.index].id
  tags = var.tags
}

# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = length(aws_subnet.private)
  tags = var.tags
}

# Create a route table for private subnets
resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "private-${count.index + 1}" })
}

# Associate private subnets with the route table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Create a default route in the private route table through the NAT Gateway
resource "aws_route" "private" {
  count               = length(aws_subnet.private)
  route_table_id      = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id      = aws_nat_gateway.nat[count.index].id
}
