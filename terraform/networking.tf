resource "aws_subnet" "mymysql" {
  vpc_id            = aws_vpc.mymysql.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = "mymysql_subnet"
  }
}

resource "aws_internet_gateway" "mymysql" {
  vpc_id = aws_vpc.mymysql.id
}

resource "aws_route_table" "mymysql" {
  vpc_id = aws_vpc.mymysql.id
  tags = {
    Name = "mymysql_route_table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.mymysql.id
  route_table_id = aws_route_table.mymysql.id
}

resource "aws_route" "mymysql" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.mymysql.id
  gateway_id             = aws_internet_gateway.mymysql.id
}

