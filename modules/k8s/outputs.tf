output "namespace" {
  value = kubernetes_namespace.ns.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.httpbin.metadata[0].name
}

output "service_cluster_ip" {
  value = kubernetes_service.httpbin.spec[0].cluster_ip
}

output "service_node_port" {
  value       = try(kubernetes_service.httpbin.spec[0].port[0].node_port, null)
}
