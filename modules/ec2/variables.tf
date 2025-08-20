variable "name" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "tags" {
  type = map(string)
}

variable "create_ssm_role" {
  type    = bool
  default = true
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "ami_id" {
  type    = string
  default = null
}

variable "key_name" {
  type    = string
  default = null
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_token" {
  type    = string
  default = "epta-k3s"
}
variable "nlb_mgmt_dns_name" {
  type = string
}
