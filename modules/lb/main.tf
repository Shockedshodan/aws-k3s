locals {
  lb_names = {
    public   = "${var.name}-alb-public"
    internal = "${var.name}-alb-internal"
    nlb_mgmt = "${var.name}-nlb-mgmt"
  }


  lb_sg_names = {
    public   = "${var.name}-alb-public-sg"
    internal = "${var.name}-alb-internal-sg"
    nlb_mgmt = "${var.name}-nlb-sg"
  }

  subnets = {
    public  = var.public_subnet_ids
    private = var.private_subnet_ids
  }

  tg_health_check = {
    path    = "/status/200"
    matcher = "200-399"
  }
}

module "alb_public" {
  source = "terraform-aws-modules/alb/aws"

  name     = local.lb_names.public
  vpc_id   = var.vpc_id
  subnets  = local.subnets.public
  internal = false

  # Because it´s a test project I don´t want to enable deletion protection by default
  enable_deletion_protection = false
  create_security_group      = true
  security_group_name        = local.lb_sg_names.public

  security_group_ingress_rules = {
    http_80_all = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "HTTP from anywhere"
    }
  }
  security_group_egress_rules = {
    all = { ip_protocol = "-1", cidr_ipv4 = "0.0.0.0/0" }
  }

  target_groups = {
    tg = {
      name_prefix       = "${var.name_prefix}pub"
      protocol          = "HTTP"
      port              = var.host_port
      target_type       = "instance"
      health_check      = local.tg_health_check
      create_attachment = false
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      fixed_response = {
        status_code  = "405"
        content_type = "text/plain"
        message_body = "Method not allowed"
      }

      rules = {
        get_only = {
          priority = 10
          actions  = [{ type = "forward", target_group_key = "tg" }]
          conditions = [
            { http_request_method = { values = ["GET"] } },
            { path_pattern = { values = ["/get*", "/status/200"] } }
          ]
        }
      }
    }
  }

  tags = var.tags
}

module "alb_internal" {
  source = "terraform-aws-modules/alb/aws"


  name     = local.lb_names.internal
  vpc_id   = var.vpc_id
  subnets  = local.subnets.private
  internal = true

  enable_deletion_protection = false
  create_security_group      = true
  security_group_name        = local.lb_sg_names.internal

  security_group_ingress_rules = {
    http_80_vpc = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = var.vpc_cidr
      description = "HTTP from VPC"
    }
  }
  security_group_egress_rules = {
    all = { ip_protocol = "-1", cidr_ipv4 = var.vpc_cidr }
  }

  target_groups = {
    tg = {
      name_prefix       = "${var.name_prefix}int"
      protocol          = "HTTP"
      port              = var.host_port
      target_type       = "instance"
      health_check      = local.tg_health_check
      create_attachment = false
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      fixed_response = {
        status_code  = "405"
        content_type = "text/plain"
        message_body = "Method not allowed"
      }

      rules = {
        put_only = {
          priority = 10
          actions  = [{ type = "forward", target_group_key = "tg" }]
          conditions = [
            { http_request_method = { values = ["PUT"] } },
            { path_pattern = { values = ["/put*"] } }
          ]
        }
        post_only = {
          priority = 11
          actions  = [{ type = "forward", target_group_key = "tg" }]
          conditions = [
            { http_request_method = { values = ["POST"] } },
            { path_pattern = { values = ["/post*"] } }
          ]
        }
      }
    }
  }

  tags = var.tags
}


module "nlb_mgmt" {
  source                     = "terraform-aws-modules/alb/aws"
  name                       = local.lb_names.nlb_mgmt
  load_balancer_type         = "network"
  internal                   = false
  vpc_id                     = var.vpc_id
  subnets                    = local.subnets.public
  enable_deletion_protection = false

  create_security_group = true
  security_group_name   = local.lb_sg_names.nlb_mgmt

  security_group_ingress_rules = {
    ssh = { from_port = 22, to_port = 22, ip_protocol = "tcp", cidr_ipv4 = var.admin_cidr }
    k8s = { from_port = 6443, to_port = 6443, ip_protocol = "tcp", cidr_ipv4 = var.admin_cidr }
  }
  security_group_egress_rules = {
    all = { ip_protocol = "-1", cidr_ipv4 = "0.0.0.0/0" }
  }

  listeners = {
    ssh = { port = 22, protocol = "TCP", forward = { target_group_key = "ssh" } }
    k8s = { port = 6443, protocol = "TCP", forward = { target_group_key = "k8s" } }
  }

  target_groups = {
    ssh = {
      name_prefix       = "ssh-"
      protocol          = "TCP"
      port              = 22
      target_type       = "instance"
      health_check      = { protocol = "TCP" }
      create_attachment = false
    }
    k8s = {
      name_prefix       = "k8s-"
      protocol          = "TCP"
      port              = 6443
      target_type       = "instance"
      health_check      = { protocol = "TCP" }
      create_attachment = false
    }
  }
  tags = var.tags
}
