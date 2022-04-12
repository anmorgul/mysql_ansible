resource "aws_security_group" "ssh_traffic" {
  vpc_id = aws_vpc.mymysql.id
  name   = "allow_ssh_traffic"
  description = "Allow ssh traffic"
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "allow_ssh_traffic"
  }
}

resource "aws_security_group" "mysql_traffic" {
  vpc_id = aws_vpc.mymysql.id
  name   = "allow_mysql_traffic"
  description = "Allow mysql traffic"
  ingress {
    description = "TLS from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "allow_mysql_traffic"
  }
}
