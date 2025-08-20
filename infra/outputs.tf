output "nlb_mgmt_dns_name" {
  value       = module.lb.nlb_mgmt_dns_name
  description = "DNS name of the NLB management interface"
}

output "public_alb_dns_name" {
  value       = module.lb.public_alb_dns_name
  description = "DNS name of the public ALB"
}

output "internal_alb_dns_name" {
  value       = module.lb.internal_alb_dns_name
  description = "DNS name of the internal ALB"
  
}