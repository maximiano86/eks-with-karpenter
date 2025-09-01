output "vpc_id" {
  value       = aws_vpc.this.id
  description = "ID of the created VPC"
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private : s.id]
  description = "List of private subnet IDs"
}

output "public_subnet_cidrs" {
  value       = { for s in aws_subnet.public : s.availability_zone => s.cidr_block }
  description = "Map of public subnet CIDRs by AZ"
}

output "private_subnet_cidrs" {
  value       = { for s in aws_subnet.private : s.availability_zone => s.cidr_block }
  description = "Map of private subnet CIDRs by AZ"
}
