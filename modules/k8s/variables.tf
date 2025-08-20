variable "kubeconfig_path" {
  description = "Kubeconfig path"
  type       = string
}
variable "namespace" {
  description = "Namespace for httpbin"
  type        = string
  default     = "httpbin"
}

variable "image" {
  description = "Container image to deploy"
  type        = string
  default     = "kennethreitz/httpbin:latest"
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 1
}

variable "service_type" {
  description = "Kubernetes Service type (ClusterIP or NodePort)"
  type        = string
  default     = "NodePort"
  validation {
    condition     = contains(["ClusterIP", "NodePort"], var.service_type)
    error_message = "service_type must be either ClusterIP or NodePort"
  }
}

variable "node_port" {
  description = "If using NodePort, the fixed nodePort to expose (30000-32767)"
  type        = number
  default     = 30080
}

variable "container_port" {
  description = "Port exposed by httpbin container (httpbin listens on 80)"
  type        = number
  default     = 80
}

variable "labels" {
  description = "Extra labels to attach to resources"
  type        = map(string)
  default     = {}
}
