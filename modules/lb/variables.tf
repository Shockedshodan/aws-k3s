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
  description = "Port on targets for the ALB"
  default     = 80
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