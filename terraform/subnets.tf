resource "aws_subnet" "mymysql" {
  vpc_id            = aws_vpc.mymysql.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = "mymysql_subnet"
  }
}
