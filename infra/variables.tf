variable "ssh_user" {
  type    = string
  default = "ec2-user"
}

variable "name" {
  type        = string
  description = "Base name for all resources"
  default     = "epta-k3s"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "epta-httpbin-test"
}

variable "tags_extra" {
  type        = map(string)
  description = "Extra tags to add to all resources"
  default     = {}
}

variable "admin_cidrs" {
  type        = list(string)
  description = "CIDR blocks for administrative access"
  default     = ["192.168.1.0/24"]
}

variable "cluster_token" {
  type        = string
  description = "Token for cluster access"
  default     = "epta-k3s"
}