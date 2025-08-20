output "public_alb_dns_name" {
  value = module.alb_public.dns_name
}

output "internal_alb_dns_name" {
  value = module.alb_internal.dns_name
}

output "public_tg_arn" {
  value = module.alb_public.target_groups["tg"].arn
}

output "internal_tg_arn" {
  value = module.alb_internal.target_groups["tg"].arn
}

output "public_listener_arn" {
  value = module.alb_public.listeners["http"].arn
}

output "internal_listener_arn" {
  value = module.alb_internal.listeners["http"].arn
}

output "public_sg_id" {
  value = module.alb_public.security_group_id
}

output "internal_sg_id" {
  value = module.alb_internal.security_group_id
}

output "nlb_sg_id" {
  value = module.nlb_mgmt.security_group_id
}


output "ssh_tg_arn" {
  value = module.nlb_mgmt.target_groups["ssh"].arn
}

output "k8s_tg_arn" {
  value = module.nlb_mgmt.target_groups["k8s"].arn
} 

output "nlb_mgmt_dns_name" {
  value = module.nlb_mgmt.dns_name
}