locals {
  public_subnet_count       = 4
  private_subnet_count      = 4
  public_subnets_cidr_base  = 8
  private_subnets_cidr_base = 12
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs = slice(data.aws_availability_zones.available.names, 0, local.public_subnet_count + local.private_subnet_count)

  public_subnets  = cidrsubnet(var.vpc_cidr_block, 8, range(local.public_subnet_count))
  private_subnets = cidrsubnet(var.vpc_cidr_block, 8, range(local.private_subnet_count, local.public_subnet_count + local.private_subnet_count))

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    "Name" = var.vpc_name
  }
}
