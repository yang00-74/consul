variable "name" {
  description = "Used to name various infrastructure components"
  default     = "consul-e2e"
}
resource "random_pet" "e2e" {
}

locals {
  random_name = "${var.name}-${random_pet.e2e.id}"
}

# First generate key pair for EC2 instances
module "keys" {
  name    = local.random_name
  path    = "${path.root}/keys"
  source  = "mitchellh/dynamic-keys/aws"
  version = "v2.0.0"
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

module "consul-oss" {
  source                 = "hashicorp/consul-oss/aws"
  version                = "0.1.3"
  allowed_inbound_cidrs  = var.allowed_inbound_cidrs
  instance_type          = var.instance_type
  consul_version         = var.consul_version
  consul_cluster_version = var.consul_cluster_version
  acl_bootstrap_bool     = var.acl_bootstrap_bool
  key_name               = module.keys.key_name
  name_prefix            = var.name_prefix
  vpc_id                 = module.vpc.vpc_id
  public_ip              = var.public_ip
  consul_servers         = var.consul_servers
  consul_clients         = var.consul_clients
  consul_config          = var.consul_config
  enable_connect         = var.enable_connect
  owner                  = var.owner
}
