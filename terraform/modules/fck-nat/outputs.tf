output "instance_id" {
  description = "The ID of the fck-nat instance"
  value       = aws_instance.fck_nat.id
}

output "public_ip" {
  description = "The public Elastic IP assigned to fck-nat"
  value       = aws_eip.fck_nat.public_ip
}

output "network_interface_id" {
  description = "The primary network interface ID of fck-nat"
  value       = aws_instance.fck_nat.primary_network_interface_id
}

