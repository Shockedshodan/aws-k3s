variable "aws_region" {
  type        = string
  description = "AWS region to deploy to"
  default     = "us-west-2"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
  default     = "epta-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# Pick two AZs for simplicity
variable "azs" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}

# Match /24s for each AZ
variable "private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "tags" {
  type = map(string)
  default = {
    Project  = "epta-httpbin-vpc"
    Teraform = "true"
  }
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway"
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "Enable single NAT Gateway"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in the VPC"
  default     = true

}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Map public IP on launch for public subnets"
  default     = false
}
