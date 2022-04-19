provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

# link to keys
data "template_file" "mymysql_public_key" {
  template = file("${var.mymysql_public_key_path}")
}

# Save Key pair
resource "aws_key_pair" "mymysql" {
  key_name   = var.mymysql_public_key_name
  public_key = data.template_file.mymysql_public_key.rendered
}

# Virtual Private Cloud
resource "aws_vpc" "petclinic" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.app_name}_vpc"
  }
}

# Subnet
resource "aws_subnet" "mymysql" {
  vpc_id            = aws_vpc.petclinic.id
  cidr_block        = var.mymysql_subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.app_name}_mymysql_subnet"
  }
}

# Route table
resource "aws_route_table" "mymysql" {
  vpc_id = aws_vpc.petclinic.id
  tags = {
    Name = "${var.app_name}_mymysql_route_table"
  }
}

# Internet gateway
resource "aws_internet_gateway" "petclinic" {
  vpc_id = aws_vpc.petclinic.id
}

# Security group for ssh
resource "aws_security_group" "ssh_traffic" {
  vpc_id      = aws_vpc.petclinic.id
  name        = "allow_ssh_traffic"
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
    "Name" = "${var.app_name}_allow_ssh_traffic"
  }
}

# Security group for mysql
resource "aws_security_group" "mysql_traffic" {
  vpc_id      = aws_vpc.petclinic.id
  name        = "allow_mysql_traffic"
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
    "Name" = "${var.app_name}_allow_mysql_traffic"
  }
}

# Route table association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.mymysql.id
  route_table_id = aws_route_table.mymysql.id
}

# Route
resource "aws_route" "mymysql" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.mymysql.id
  gateway_id             = aws_internet_gateway.petclinic.id
}

# Network interface
resource "aws_network_interface" "mymysql" {
  subnet_id       = aws_subnet.mymysql.id
  private_ips     = [var.mymysql_private_ips]
  security_groups = [aws_security_group.mysql_traffic.id, aws_security_group.ssh_traffic.id]
  tags = {
    Name = "mymysql_primary_network_interface"
  }
}

# Elasic IP
resource "aws_eip" "mymysql" {
  # instance = aws_instance.mymysql.id
  network_interface = aws_network_interface.mymysql.id
  vpc               = true
}

# Most recent ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# EC@ instance

resource "aws_instance" "mymysql" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.mymysql_public_key_name
  #  vpc_security_group_ids = [aws_security_group.mysql_traffic.id, aws_security_group.ssh_traffic.id]
  network_interface {
    network_interface_id = aws_network_interface.mymysql.id
    device_index         = 0
  }
  tags = {
    Name = "mymysql_instance"
  }
}
