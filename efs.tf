module "efs" {
  source = "rhythmictech/efs-filesystem/aws"
  name                    = "storage"
  subnets                 = module.vpc.public_subnets
  vpc_id                  = module.vpc.vpc_id
  allowed_security_groups = [aws_security_group.ec2-sg.id]
}