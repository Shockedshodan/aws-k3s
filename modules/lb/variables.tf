variable "name" {
  type        = string
  description = "Base name for ALBs and related resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR (for internal ALB ingress restriction)"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the internet-facing ALB"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the internal ALB"
}

variable "host_port" {
  type        = number
  description = "Port on targets (httpbin container port)"
  default     = 80
}

variable "target_type" {
  type        = string
  description = "Target type for TGs (instance|ip|lambda)"
  default     = "instance"
}

variable "target_instance_ids" {
  type        = list(string)
  description = "Optional instance IDs to register in both TGs"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
  default     = {}
}

variable "name_prefix" {
  type        = string
  description = "Prefix for all resources"
  default     = "ept"
}

variable "admin_cidr" {
  type        = string
  description = "CIDR block for admin access"
  default     = "192.168.1.0/24"
}