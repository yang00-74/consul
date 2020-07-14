# First generate key pair for EC2 instances
resource "tls_private_key" "pvkey" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "consul-key"
  public_key = tls_private_key.pvkey.public_key_openssh
}

resource "local_file" "key-pair" {
  content  = module.key_pair.this_key_pair_fingerprint
  filename = "${path.module}/consul-key.pem"
}

#Create VPC with public of private subnets 

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = var.vpc_name
  cidr = var.vpc_cidr
  azs = var.vpc_az
  public_subnets = var.public_subnet_cidr
  enable_nat_gateway = true
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = vpc.aws_subnet.public.*.id

  create_duration = "30s"
}


module "consul-oss" {
  source                 = "hashicorp/consul-oss/aws"
  version                = "0.1.3"
  allowed_inbound_cidrs  = module.vpc.public_subnets_cidr_blocks
  instance_type          = var.instance_type
  consul_version         = var.consul_version
  consul_cluster_version = var.consul_cluster_version
  acl_bootstrap_bool     = var.acl_bootstrap_bool
  key_name               = module.key_pair.this_key_pair_key_name
  name_prefix            = var.name_prefix
  vpc_id                 = module.vpc.vpc_id
  public_ip              = var.public_ip
  consul_servers         = var.consul_servers
  consul_clients         = var.consul_clients
  consul_config          = var.consul_config
  enable_connect         = var.enable_connect
  owner                  = var.owner
}
