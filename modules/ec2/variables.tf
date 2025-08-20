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

variable "key_name"      { 
    type = string
    default = null
} 

variable "container_image" { 
    type = string
    default = "kennethreitz/httpbin"
}
variable "container_port"  { 
    type = number
    default = 80
}
variable "host_port"       { 
    type = number
    default = 8080
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_internal_sg_id" {
  type = string
}

variable "alb_public_sg_id" {
  type = string
  
}


variable "cluster_token" {
  type    = string
  default = "epta-k3s"
}

variable "nlb_mgmt_dns_name" {
  type    = string
}