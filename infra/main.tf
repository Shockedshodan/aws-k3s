locals {
    kubeconfig_raw = base64decode(replace(data.external.kubeconfig.result.kubeconfig,  " ", ""))
    kubeconfig_yaml_replaced_host = replace(
     local.kubeconfig_raw,
    "/server:\\s*https:\\/\\/127\\.0\\.0\\.1:(\\d+)/",
    "server: https://${module.lb.nlb_mgmt_dns_name}:$1"
  )
    kubeconfig = yamldecode(local.kubeconfig_yaml_replaced_host)
}




# module "s3_state" {
#   source = "../modules/s3-state"

#   bucket_name         = "epta-tf-state-bucket"
#   versioning_status    = "Enabled"
#   sse_algorithm        = "AES256"
#   dynamodb_table_name  = "epta-tf-state-lock"
# }


resource "aws_key_pair" "ssh_key" {
  key_name   = "local-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

module "vpc" {
  source = "../modules/vpc"

  vpc_name = "epta-k3ss-vpc"
  vpc_cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true
  enable_dns_support     = true
  map_public_ip_on_launch = false

  tags = {
    Project  = "epta-httpbin-test"
    Terraform = "true"
  }
}


module "lb" {
  source = "../modules/lb"

  name               = "epta-k3ss-alb"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets

  host_port = 80

  tags = {
    Project = "epta-httpbin-test"
    Terraform = "true"
  }
  admin_cidr = "77.165.233.0/24"

}

module "ec2" {
  source  = "../modules/ec2"

  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = "10.0.0.0/16"
  name                        = "epta-k3ss-ec2"
  ami_id                      = "ami-01102c5e8ab69fb75" 
  instance_type               = "t3.small"
  private_subnet_ids          = module.vpc.private_subnets
  key_name                    = aws_key_pair.ssh_key.key_name
  create_ssm_role             = true
  alb_internal_sg_id          = module.lb.internal_sg_id
  alb_public_sg_id            = module.lb.public_sg_id
  host_port                   = 80
  # Hardcoded, not flexible
  nlb_mgmt_dns_name           = module.lb.nlb_mgmt_dns_name


  tags = {
    Project  = "epta-httpbin-test"
    Terraform = "true"
  }
  
}

resource "aws_security_group_rule" "allow_public_alb_to_httpbin" {
  type                     = "ingress"
  from_port                = 30080
  to_port                  = 30080
  protocol                 = "tcp"
  security_group_id        = module.ec2.ec2_sg_id
  source_security_group_id = module.lb.public_sg_id
  description              = "Allow public ALB to reach app"
}

resource "aws_security_group_rule" "allow_internal_alb_to_httpbin" {
  type                     = "ingress"
  from_port                = 30080
  to_port                  = 30080
  protocol                 = "tcp"
  security_group_id        = module.ec2.ec2_sg_id
  source_security_group_id = module.lb.internal_sg_id
  description              = "Allow internal ALB to reach app"
}

resource "aws_security_group_rule" "allow_nlb_to_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.ec2.ec2_sg_id
  source_security_group_id = module.lb.nlb_sg_id
  description              = "Allow NLB to reach ssh"
}


resource "aws_security_group_rule" "allow_ssh_from_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.ec2.ec2_sg_id
  cidr_blocks       = ["77.165.233.0/24"] 
  description       = "SSH from admin CIDR via NLB"
}

resource "aws_security_group_rule" "allow_k8s_from_admin" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  security_group_id = module.ec2.ec2_sg_id
  cidr_blocks       = ["77.165.233.0/24"]
  description       = "Kubernetes API from admin CIDR via NLB"
}

resource "aws_security_group_rule" "allow_nlb_to_kubeapi" {
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = module.ec2.ec2_sg_id
  source_security_group_id = module.lb.nlb_sg_id
  description              = "Allow NLB to reach kubeapi"
}
resource "aws_security_group_rule" "vpc_endpoints_egress" {
  type = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["10.0.101.0/24", "10.0.102.0/24"]
  security_group_id = module.vpc.endpoints_security_group_id
  description = "Allow outbound traffic to VPC endpoints"
}
resource "aws_security_group_rule" "ec2_to_vpc_endpoints" {
  type = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"]
  security_group_id = module.ec2.ec2_sg_id
  description = "Allow outbound traffic to VPC endpoints"
}


resource "aws_lb_target_group_attachment" "public" {
  target_group_arn = module.lb.public_tg_arn
  target_id        = module.ec2.instance_id
  port             = 30080
}
resource "aws_lb_target_group_attachment" "internal" {
  target_group_arn = module.lb.internal_tg_arn
  target_id        = module.ec2.instance_id
  port             = 30080
}

resource "aws_lb_target_group_attachment" "nlb_ssh" {
  target_group_arn  = module.lb.ssh_tg_arn
  target_id = module.ec2.instance_id
  port = 22
}

resource "aws_lb_target_group_attachment" "nlb_k8s" {
  target_group_arn  = module.lb.k8s_tg_arn
  target_id = module.ec2.instance_id
  port = 6443
}


data "external" "kubeconfig" {
  program = [
    "/usr/bin/ssh",
    "-o UserKnownHostsFile=/dev/null",
    "-o StrictHostKeyChecking=no",
    "${var.ssh_user}@${module.lb.nlb_mgmt_dns_name}",
    "echo '{\"kubeconfig\":\"'$(sudo cat /etc/rancher/k3s/k3s.yaml | base64)'\"}'"
  ]
}


resource "local_sensitive_file" "kubeconfig" {
  filename = "${path.module}/.generated/kubeconfig"
  content  = yamlencode(local.kubeconfig) 
}

module "k8s-httpbin" {
  source = "../modules/k8s"

  kubeconfig_path = local_sensitive_file.kubeconfig.filename
  namespace       = "httpbin"
  image           = "kennethreitz/httpbin:latest"
  replicas        = 1
  service_type    = "NodePort"
  node_port       = 30080
  container_port  = 80
  labels          = {
    app = "httpbin"
    env = "test"
  }
  
}