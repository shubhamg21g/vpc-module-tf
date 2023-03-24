provider "aws" {
  profile = "terraform"
  region  = "us-west-2"
}

module "vpc" {
  source             = "../../modules/vpc"
  appname            = "retro"
  env                = "prod"
  vpc_cidr_block     = "192.168.0.0/16"
  public_cidr_block  = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  private_cidr_block = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
  azs                = ["us-west-2a", "us-west-2b", "us-west-2c"]
  tags = {
    Owner = "prod-team"
  }
}

module "jenkins" {
  source          = "../../modules/jenkins"
  appname         = "jenkins"
  env             = "prod"
  instance_type   = "t2.micro"
  key_pair        = "oregon-key"
  subnets         = module.vpc.public_subnet_ids
  security_groups = [module.vpc.security_groups]
  tags = {
    Owner = "dev-team"
  }
}

module "eks" {
  source                  = "../../modules/eks-cluster"
  appname                 = "eks-cluster"
  env                     = "prod"
  aws_public_subnet       = module.vpc.public_subnet_ids
  vpc_id                  = module.vpc.vpc_id
  security_group_ids      = [module.vpc.security_groups]
  endpoint_public_access  = true
  endpoint_private_access = false
  public_access_cidrs     = ["0.0.0.0/0"]
  node_group_name         = "worker-node"
  scaling_desired_size    = 1
  scaling_max_size        = 1
  scaling_min_size        = 1
  instance_types          = ["t3.medium"]
  key_pair                = "oregon-key"
}