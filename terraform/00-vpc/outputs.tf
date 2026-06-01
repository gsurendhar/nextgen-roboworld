output "vpc_id" {
  value       = module.vpc.vpc_id
}

output "igw_id" {
  value       = module.vpc.igw_id
}

output "public_subnet_id" {
  value       = module.vpc.public_subnet_ids
}

output "public_subnet_id-1a" {
  value       = module.vpc.public_subnet_id-1a
}

output "public_subnet_id-1b" {
  value       = module.vpc.public_subnet_id-1b
}

output "private_subnet_id-1a" {
  value       = module.vpc.private_subnet_id-1a
}

output "private_subnet_id-1b" {
  value       = module.vpc.private_subnet_id-1b
}

output "database_subnet_id-1a" {
  value       = module.vpc.database_subnet_id-1a
}

output "database_subnet_id-1b" {
  value       = module.vpc.database_subnet_id-1b
}

output "public_route_table_id" {
  value = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  value = module.vpc.private_route_table_id
}

output "database_route_table_id" {
  value = module.vpc.database_route_table_id
}