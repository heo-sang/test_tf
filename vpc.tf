#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "snet2_2_vpc" {
  cidr_block = "11.0.0.0/16"

  tags = tomap({
    "Name"                                      = "snet2_2_node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}
data "aws_availability_zones" "available" {
 state = "available"
}
resource "aws_subnet" "snet2_2_public" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "11.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.snet2_2_vpc.id

  tags = tomap({
    "Name"                                      = "snet2_2_public_subnet${count.index+1}",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
    "kubernetes.io/role/elb" = "1"
  })
}
resource "aws_subnet" "snet2_2_private" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "11.0.${count.index+2}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.snet2_2_vpc.id

  tags = tomap({
    "Name"                                      = "snet2_2_private_subnet${count.index+1}",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_internet_gateway" "snet2_2_igw" {
  vpc_id = aws_vpc.snet2_2_vpc.id

  tags = {
    Name = "snet2_2_igw"
  }
}

resource "aws_route_table" "snet2_2_rt" {
  vpc_id = aws_vpc.snet2_2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.snet2_2_igw.id
  }
}
resource "aws_route_table_association" "snet2_2" {
  count = 2

  subnet_id      = aws_subnet.snet2_2_public.*.id[count.index]
  route_table_id = aws_route_table.snet2_2_rt.id
}

