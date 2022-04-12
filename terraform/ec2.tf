resource "aws_network_interface" "mymysql" {
  subnet_id   = aws_subnet.mymysql.id
  private_ips = [var.mymysql_private_ips]
  security_groups = [aws_security_group.mysql_traffic.id, aws_security_group.ssh_traffic.id]
  tags = {
    Name = "mymysql_primary_network_interface"
  }
}

resource "aws_instance" "mymysql" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
#  vpc_security_group_ids = [aws_security_group.mysql_traffic.id, aws_security_group.ssh_traffic.id]
  network_interface {
    network_interface_id = aws_network_interface.mymysql.id
    device_index         = 0
  }
}
