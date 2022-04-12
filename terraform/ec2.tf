resource "aws_network_interface" "mymysql" {
  subnet_id       = aws_subnet.mymysql.id
  private_ips     = [var.mymysql_private_ips]
  security_groups = [aws_security_group.mysql_traffic.id, aws_security_group.ssh_traffic.id]
  tags = {
    Name = "mymysql_primary_network_interface"
  }
}

resource "aws_key_pair" "mymysql" {
  key_name   = "${var.mymysql_public_key_name}"
  public_key = data.template_file.mymysql_public_key.rendered
}

resource "aws_eip" "mymysql" {
  # instance = aws_instance.mymysql.id
  network_interface = aws_network_interface.mymysql.id
  vpc      = true
}

resource "aws_instance" "mymysql" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name   = "${var.mymysql_public_key_name}"
  #  vpc_security_group_ids = [aws_security_group.mysql_traffic.id, aws_security_group.ssh_traffic.id]
  network_interface {
    network_interface_id = aws_network_interface.mymysql.id
    device_index         = 0
  }
  tags = {
    Name = "mymysql_instance"
  }
}
