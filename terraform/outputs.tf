output "awc_vpc" {
  value = aws_vpc.petclinic.id
}

# output "db_public_ip" {
#   value       = aws_instance.db.public_ip
#   description = "The public IP of the db Instance"
# }

output "dns_name_nlb" {
  value = aws_lb.nlb.dns_name
}