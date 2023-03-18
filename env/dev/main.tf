provider "aws" {
  profile = "terraform"
  region  = "us-west-2"
}

module "vpc" {
  source             = "../../modules/vpc"
  appname            = "retro"
  env                = "dev"
  vpc_cidr_block     = "192.168.0.0/16"
  public_cidr_block  = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  private_cidr_block = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
  azs                = ["us-west-2a", "us-west-2b", "us-west-2c"]
  tags = {
    Owner = "dev-team"
  }
}

module "loadbalancer" {
  source                 = "../../modules/loadbalancer"
  appname                = "retro-lb"
  env                    = "dev"
  internal               = "false"
  type                   = "application" #application #network
  subnets                = module.vpc.public_subnet_ids
  security_groups        = [module.vpc.security_groups]
  autoscaling_group_name = module.autoscaling.autoscaling_group_name
  vpc_id                 = module.vpc.vpc_id
  tags = {
    Owner = "dev-team"
  }
}

module "autoscaling" {
  source              = "../../modules/autoscaling"
  appname             = "retro-asg"
  env                 = "dev"
  security_groups     = [module.vpc.security_groups]
  subnets             = module.vpc.public_subnet_ids
  vpc_zone_identifier = module.vpc.public_subnet_ids
  instance_type       = "t2.micro"
  user_data_base64    = "IyEvYmluL2Jhc2gKc3VkbyBhcHQtZ2V0IHVwZGF0ZQpzdWRvIGFwdC1nZXQgaW5zdGFsbCBuZ2lueCAteQpzdWRvIHN5c3RlbS1jb250ZW50IHN0YXJ0IG5naW54CgpjZCAvdmFyL3d3dy9odG1sCmVjaG8gIkhlbGxvLCBUZXJyYWZvcmYgJiBBV1MgQVNHIiA+IGluZGV4Lmh0bWw="
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  policy_type         = "SimpleScaling" #"SimpleScaling"  #"target_tracking_policy" #"StepScaling"
  tags = {
    Owner = "dev-team"
  }
}