module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"
  name = "jb_vpc"
  cidr = "10.0.0.0/16"
  enable_dns_hostnames = true
  azs            = var.azs_list
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

data "aws_vpc" "main" {
  id = module.vpc.vpc_id
}