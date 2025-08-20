locals {
  name             = var.name
  ec2_name         = "${var.name}-ec2"
  role_name        = "${var.name}-role"
  instance_profile = "${var.name}-profile"

  create_ssm_role             = var.create_ssm_role
  primary_private_subnet      = var.private_subnet_ids[0]
  associate_public_ip_address = false

  tags = var.tags

  ssm_core_policy_arn  = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  assume_role_services = ["ec2.amazonaws.com"]

  user_data_path = "${path.module}/templates/install-k3s.sh.tftpl"

  k3s_vars = {
    mode         = "server"
    tokens       = [var.cluster_token]
    server_hosts = []
    cluster_init = ["true"]
    disable      = []
    alt_names    = [var.nlb_mgmt_dns_name]
    node_taints  = []
  }
}

resource "aws_security_group" "ec2" {
  name        = local.ec2_name
  description = "EC2 httpbin"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = local.assume_role_services
    }
  }
}


resource "aws_iam_role" "this" {
  count              = var.create_ssm_role ? 1 : 0
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  count      = local.create_ssm_role ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = local.ssm_core_policy_arn
}

resource "aws_iam_instance_profile" "this" {
  count = local.create_ssm_role ? 1 : 0
  name  = local.instance_profile
  role  = aws_iam_role.this[0].name
}

module "ec2" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = ">= 6.0"
  name                        = local.ec2_name
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = local.primary_private_subnet
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  key_name                    = var.key_name
  associate_public_ip_address = local.associate_public_ip_address


  iam_instance_profile = local.create_ssm_role ? aws_iam_instance_profile.this[0].name : null

  user_data = templatefile(local.user_data_path, local.k3s_vars)

  tags = local.tags
}
