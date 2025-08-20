resource "aws_security_group_rule" "allow_public_alb_to_httpbin" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = var.ec2_sg_id
  source_security_group_id = var.public_sg_id
  description              = "Allow public ALB to reach app"
}

resource "aws_security_group_rule" "allow_internal_alb_to_httpbin" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = var.ec2_sg_id
  source_security_group_id = var.internal_sg_id
  description              = "Allow internal ALB to reach app"
}

resource "aws_security_group_rule" "allow_nlb_to_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = var.ec2_sg_id
  source_security_group_id = var.nlb_sg_id
  description              = "Allow NLB to reach ssh"
}


resource "aws_security_group_rule" "allow_ssh_from_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = var.ec2_sg_id
  cidr_blocks       = ["77.165.233.0/24"] # ideally a /32 with your current IP
  description       = "SSH from admin CIDR via NLB (source IP preserved)"
}

resource "aws_security_group_rule" "allow_k8s_from_admin" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  security_group_id = var.ec2_sg_id
  cidr_blocks       = ["77.165.233.0/24"]
  description       = "Kubernetes API from admin CIDR via NLB (source IP preserved)"
}

resource "aws_security_group_rule" "allow_nlb_to_kubeapi" {
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = var.ec2_sg_id
  source_security_group_id = var.nlb_sg_id
  description              = "Allow NLB to reach kubeapi"
}
resource "aws_security_group_rule" "vpc_endpoints_egress" {
  type = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["10.0.101.0/24", "10.0.102.0/24"]
  security_group_id = var.vpc_endpoints_security_group_id
  description = "Allow outbound traffic to VPC endpoints"
}
resource "aws_security_group_rule" "ec2_to_vpc_endpoints" {
  type = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"]
  security_group_id = var.ec2_sg_id
  description = "Allow outbound traffic to VPC endpoints"
}


resource "aws_lb_target_group_attachment" "public" {
  target_group_arn = var.public_tg_arn
  target_id        = var.ec2_instance_id
  port             = 30080
}
resource "aws_lb_target_group_attachment" "internal" {
  target_group_arn = var.internal_tg_arn
  target_id        = var.ec2_instance_id
  port             = 30080
}

resource "aws_lb_target_group_attachment" "nlb_ssh" {
  target_group_arn  = var.ssh_tg_arn
  target_id = var.ec2_instance_id
  port = 22
}

resource "aws_lb_target_group_attachment" "nlb_k8s" {
  target_group_arn  = var.k8s_tg_arn
  target_id = var.ec2_instance_id
  port = 6443
}