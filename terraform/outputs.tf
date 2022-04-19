output "awc_vpc" {
  value = aws_vpc.petclinic.id
}

output "mymysql_public_ip" {
  value       = aws_instance.mymysql.public_ip
  description = "The public IP of the mymysql Instance"
}