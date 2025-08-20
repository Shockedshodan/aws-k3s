resource "aws_security_group" "ec2" {
  name        = "${var.name}-ec2"
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
        type = "Service"
        identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "this" {
  count              = var.create_ssm_role ? 1 : 0
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  count      = var.create_ssm_role ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_ssm_role ? 1 : 0
  name  = "${var.name}-profile"
  role  = aws_iam_role.this[0].name
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 6.0" 
  name                        = "${var.name}-ec2"
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  key_name                    = var.key_name
  associate_public_ip_address = false


  iam_instance_profile = var.create_ssm_role ? aws_iam_instance_profile.this[0].name : null

  user_data = templatefile("${path.module}/templates/install-k3s.sh.tftpl", {
        mode         = "server"
        tokens       = [var.cluster_token]
        server_hosts = []
        cluster_init = ["true"]
        disable      = []
        alt_names    = [var.nlb_mgmt_dns_name]
        node_taints  = []
  })

  tags = var.tags
}
