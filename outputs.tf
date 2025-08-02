output "vpc_id" {
  value       = aws_vpc.dev.id
  description = "The ID of the custom VPC"
}

output "subnet_id" {
  value       = aws_subnet.public.id
  description = "The ID of the public subnet"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "Internet Gateway ID"
}

output "security_group_id" {
  value       = aws_security_group.dev.id
  description = "Security Group ID"
}

output "instance_id" {
  value       = aws_instance.dev.id
  description = "The EC2 instance ID"
}

output "instance_public_ip" {
  value       = aws_instance.dev.public_ip
  description = "The public IP of the EC2 instance"
}

output "instance_public_dns" {
  value       = aws_instance.dev.public_dns
  description = "The public DNS name of the EC2 instance"
}

output "availability_zone" {
  value       = aws_instance.dev.availability_zone
  description = "Availability Zone of the EC2 instance"
}

output "key_pair_name" {
  value       = aws_key_pair.dev.key_name
  description = "Name of the EC2 key pair"
}

output "public_key" {
  value       = tls_private_key.dev_key.public_key_openssh
  description = "The generated public SSH key"
}

output "private_key_pem" {
  value       = tls_private_key.dev_key.private_key_pem
  sensitive   = true
  description = "The generated private key (PEM format)"
}