output "awc_vpc" {
  value = aws_vpc.mymysql.id
}

output "public_ip" {
  value       = aws_instance.mymysql.public_ip
  description = "The public IP of the mymysql Instance"
}