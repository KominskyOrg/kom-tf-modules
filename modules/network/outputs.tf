output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "nat_gateways_ids" {
  description = "The ID of the NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

output "public_route_table_ids" {
  description = "The ID of the route table for the public subnets"
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "The ID of the route table for the private subnets"
  value       = module.vpc.private_route_table_ids
}
