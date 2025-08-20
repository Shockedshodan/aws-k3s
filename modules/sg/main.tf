locals {
  protocol = "tcp"

  ports = {
    https    = 443
    ssh      = 22
    kube_api = 6443
    httpbin_app  = var.httpbin_node_port
  }

  cidrs = {
    admin                = var.admin_cidrs
    vpc_endpoints_subnet = var.vpc_endpoint_subnet_cidrs
    vpc                  = var.vpc_cidr
  }

  desc = {
    alb_public_to_app   = "Allow public ALB to reach app"
    alb_internal_to_app = "Allow internal ALB to reach app"
    nlb_to_ssh          = "Allow NLB to reach ssh"
    admin_ssh           = "SSH from admin CIDR via NLB"
    admin_k8s           = "Kubernetes API from admin CIDR via NLB"
    nlb_to_kubeapi      = "Allow NLB to reach kubeapi"
    to_vpc_endpoints    = "Allow outbound traffic to VPC endpoints"
  }
}


resource "aws_security_group_rule" "allow_public_alb_to_httpbin" {
  type                     = "ingress"
  from_port                = local.ports.httpbin_app
  to_port                  = local.ports.httpbin_app
  protocol                 = local.protocol
  security_group_id        = var.ec2_sg_id
  source_security_group_id = var.public_sg_id
  description              = local.desc.alb_public_to_app
}

resource "aws_security_group_rule" "allow_internal_alb_to_httpbin" {
  type                     = "ingress"
  from_port                = local.ports.httpbin_app
  to_port                  = local.ports.httpbin_app
  protocol                 = local.protocol
  security_group_id        = var.ec2_sg_id
  source_security_group_id = var.internal_sg_id
  description              = local.desc.alb_internal_to_app
}

resource "aws_security_group_rule" "allow_nlb_to_ssh" {
  type                     = "ingress"
  from_port                = local.ports.ssh
  to_port                  = local.ports.ssh
  protocol                 = local.protocol
  security_group_id        = var.ec2_sg_id
  source_security_group_id = var.nlb_sg_id
  description              = local.desc.nlb_to_ssh
}

resource "aws_security_group_rule" "allow_ssh_from_admin" {
  type              = "ingress"
  from_port         = local.ports.ssh
  to_port           = local.ports.ssh
  protocol          = local.protocol
  security_group_id = var.ec2_sg_id
  cidr_blocks       = local.cidrs.admin
  description       = local.desc.admin_ssh
}

resource "aws_security_group_rule" "allow_k8s_from_admin" {
  type              = "ingress"
  from_port         = local.ports.kube_api
  to_port           = local.ports.kube_api
  protocol          = local.protocol
  security_group_id = var.ec2_sg_id
  cidr_blocks       = local.cidrs.admin
  description       = local.desc.admin_k8s
}

resource "aws_security_group_rule" "allow_nlb_to_kubeapi" {
  type                     = "ingress"
  from_port                = local.ports.kube_api
  to_port                  = local.ports.kube_api
  protocol                 = local.protocol
  security_group_id        = var.ec2_sg_id
  source_security_group_id = var.nlb_sg_id
  description              = local.desc.nlb_to_kubeapi
}

resource "aws_security_group_rule" "vpc_endpoints_ingress" {
  type              = "ingress"
  from_port         = local.ports.https
  to_port           = local.ports.https
  protocol          = local.protocol
  cidr_blocks       = local.cidrs.vpc_endpoints_subnet
  security_group_id = var.vpc_endpoints_security_group_id
  description       = local.desc.to_vpc_endpoints
}

resource "aws_security_group_rule" "ec2_to_vpc_endpoints" {
  type              = "egress"
  from_port         = local.ports.https
  to_port           = local.ports.https
  protocol          = local.protocol
  cidr_blocks       = [local.cidrs.vpc]
  security_group_id = var.ec2_sg_id
  description       = local.desc.to_vpc_endpoints
}

resource "aws_lb_target_group_attachment" "public" {
  target_group_arn = var.public_tg_arn
  target_id        = var.ec2_instance_id
  port             = local.ports.httpbin_app
}

resource "aws_lb_target_group_attachment" "internal" {
  target_group_arn = var.internal_tg_arn
  target_id        = var.ec2_instance_id
  port             = local.ports.httpbin_app
}

resource "aws_lb_target_group_attachment" "nlb_ssh" {
  target_group_arn = var.ssh_tg_arn
  target_id        = var.ec2_instance_id
  port             = local.ports.ssh
}

resource "aws_lb_target_group_attachment" "nlb_k8s" {
  target_group_arn = var.k8s_tg_arn
  target_id        = var.ec2_instance_id
  port             = local.ports.kube_api
}
