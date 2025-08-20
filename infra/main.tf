locals {
  vpc_name = "${var.name}-vpc"
  lb_name  = "${var.name}-alb"
  ec2_name = "${var.name}-ec2"

  common_tags = merge(
    {
      Project   = var.project
      Terraform = "true"
    },
    var.tags_extra
  )

  # Ugh
  admin_cidrs = var.admin_cidrs
  admin_cidr  = element(var.admin_cidrs, 0)

  vpc_cidr = "10.0.0.0/16"


  ami_id = "ami-01102c5e8ab69fb75"
  # t3.micro struggled with 1g of ram eaten right after deployment.
  # Can turn off traefik and rest of the stuff but meh. Beyond the scope
  instance_type = "t3.small"

  k3s_labels = {
    app_name = "httpbin"
    env      = "test"
  }

  kubeconfig_raw = base64decode(replace(data.external.kubeconfig.result.kubeconfig, " ", ""))
  kubeconfig_yaml_replaced_host = replace(
    local.kubeconfig_raw,
    "/server:\\s*https:\\/\\/127\\.0\\.0\\.1:(\\d+)/",
    "server: https://${module.lb.nlb_mgmt_dns_name}:$1"
  )
  kubeconfig = yamldecode(local.kubeconfig_yaml_replaced_host)
}


# S3 state being commented since we don't need it in test env, but having an option to enable it later is good, eh?
# Look, dynamodb, versioning, encrypted. Noice.
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

  vpc_name = local.vpc_name
  vpc_cidr = local.vpc_cidr

  azs             = ["us-west-2a", "us-west-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = false

  tags = local.common_tags
}


module "lb" {
  source = "../modules/lb"

  name               = local.lb_name
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = local.vpc_cidr
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets



  host_port = 80

  tags = local.common_tags

  admin_cidr = local.admin_cidr

}

module "ec2" {
  source = "../modules/ec2"

  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = local.vpc_cidr
  name               = local.ec2_name
  ami_id             = local.ami_id
  instance_type      = local.instance_type
  private_subnet_ids = module.vpc.private_subnets
  key_name           = aws_key_pair.ssh_key.key_name
  create_ssm_role    = true
  cluster_token      = var.cluster_token

  # Hardcoded, not flexible
  nlb_mgmt_dns_name = module.lb.nlb_mgmt_dns_name


  tags = local.common_tags

}

module "sg" {
  source = "../modules/sg"

  ec2_sg_id                       = module.ec2.ec2_sg_id
  public_sg_id                    = module.lb.public_sg_id
  internal_sg_id                  = module.lb.internal_sg_id
  nlb_sg_id                       = module.lb.nlb_sg_id
  vpc_endpoints_security_group_id = module.vpc.endpoints_security_group_id

  ec2_instance_id = module.ec2.instance_id
  public_tg_arn   = module.lb.public_tg_arn
  internal_tg_arn = module.lb.internal_tg_arn
  ssh_tg_arn      = module.lb.ssh_tg_arn
  k8s_tg_arn      = module.lb.k8s_tg_arn

  admin_cidrs = local.admin_cidrs

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
  labels          = local.k3s_labels
}
