##################
# VPC
##################
resource "aws_default_vpc" "this" {
  tags = merge(
    {
      "Name" = "${var.name}-default-vpc"
    },
    var.tags
  )
}

##################
# Default Public Subnet
##################
resource "aws_default_subnet" "default_subnet" {
  availability_zone = data.aws_availability_zones.available.names[0]
  tags              = var.tags
}

##################
# Private subnet
##################
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_default_vpc.this.id
  cidr_block        = module.subnet_addrs.network_cidr_blocks["pvt-subnet-c"]
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-private-subnet"
    },
  )
}

#################
# routes for private subnet
#################
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_default_vpc.this.id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-private-route-table"
    },
  )
}

##############
# NAT Gateway
##############
resource "aws_eip" "nat_ip" {
  vpc = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-natgw-eip"
    },
  )
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_ip.id
  #where the nat gateway resides, all provate subnets should be able to conenct
  subnet_id = aws_default_subnet.default_subnet.id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-natgw"
    },
  )
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
  timeouts {
    create = "5m"
  }
}

##########################
# Route table association
##########################
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}