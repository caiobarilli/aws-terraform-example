output "instance_id" {
  description = "ID da instancia"
  value       = aws_instance.example-server.id
}

output "public_ip" {
  description = "IP publico da instancia"
  value       = aws_instance.example-server.public_ip
}

output "public_dns" {
  description = "dns publico"
  value       = aws_instance.example-server.public_dns
}

output "ami_id" {
  description = "ami escolhida de forma dinamica"
  value       = data.aws_ami.selected
}

output "key_pair_name" {
  description = "nome da chave"
  value       = aws_key_pair.example-key.key_name
}

output "security_group_id" {
  description = "id do SG"
  value       = aws_security_group.allow_ssh_http_https
}

output "extra_volume_devices" {
  value = var.ec2_mountpoint
}

output "example_public_ip" {
  value = aws_eip.example-server.public_ip
}
