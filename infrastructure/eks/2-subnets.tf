# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Create Public Subnet
resource "aws_subnet" "pub_sub1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.sub1_cidr
  availability_zone       = var.az1 # Change to your desired AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/eks1" = "shared"
  }
}

# Create Public Subnet
resource "aws_subnet" "pub_sub2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.sub2_cidr
  availability_zone       = var.az2 # Change to your desired AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet2"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/eks1" = "shared"
  }
}



# Connect Public Subnet to Internet Gateway
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.rt_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "rt_association1" {
  subnet_id      = aws_subnet.pub_sub1.id
  route_table_id = aws_route_table.rt_public.id
}


resource "aws_route_table_association" "rt_association2" {
  subnet_id      = aws_subnet.pub_sub2.id
  route_table_id = aws_route_table.rt_public.id
}

