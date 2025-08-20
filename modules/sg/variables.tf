variable "ec2_sg_id" {
  description = "Security group ID attached to the EC2 instance"
  type        = string
}

variable "public_sg_id" {
  description = "Security group ID of the public ALB"
  type        = string
}

variable "internal_sg_id" {
  description = "Security group ID of the internal ALB"
  type        = string
}

variable "nlb_sg_id" {
  description = "Security group ID of the NLB used for SSH and kubeapi"
  type        = string
}

variable "vpc_endpoints_security_group_id" {
  description = "Security group ID used by Interface VPC Endpoints"
  type        = string
}

variable "ec2_instance_id" {
  description = "Target EC2 instance ID for TG attachments"
  type        = string
}

variable "public_tg_arn" {
  description = "Target Group ARN for the public ALB"
  type        = string
}

variable "internal_tg_arn" {
  description = "Target Group ARN for the internal ALB"
  type        = string
}

variable "ssh_tg_arn" {
  description = "Target Group ARN for SSH on the NLB"
  type        = string
}

variable "k8s_tg_arn" {
  description = "Target Group ARN for Kubernetes API on the NLB"
  type        = string
}

variable "admin_cidrs" {
  description = "CIDR blocks for administrative access"
  type        = list(string)
  default     = ["192.168.1.0/24"]
}

variable "vpc_endpoint_subnet_cidrs" {
  description = "CIDR blocks of subnets that host the interface VPC endpoints"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_cidr" {
  description = "VPC CIDR for egress-to-endpoints rule scope"
  type        = string
  default     = "10.0.0.0/16"
}

variable "httpbin_node_port" {
  description = "NodePort on the instance for the httpbin app behind ALBs"
  type        = number
  default     = 30080
}