output "nlb_mgmt_dns_name" {
  value       = module.lb.nlb_mgmt_dns_name
  description = "DNS name of the NLB management interface"
}
output "kubeconfig" {
  value       = local.kubeconfig
  sensitive   = true
  description = "Usable kubeconfig (server rewritten to NLB DNS)"
}