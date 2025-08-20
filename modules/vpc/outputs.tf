output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "intra_subnets_cidr_blocks" {
  value = module.vpc.intra_subnets_cidr_blocks
}

output "endpoints_security_group_id" {
  value = module.vpc_endpoints.security_group_id
}