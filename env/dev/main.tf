provider "aws" {
    profile = "terraform"
    region ="us-west-2"
}

module "vpc" {
    source = "../../modules/vpc"
    appname = "student"
    env = "dev"
    vpc_cidr_block = "192.168.0.0/16"
    public_cidr_block = ["192.168.1.0/24" , "192.168.2.0/24" , "192.168.3.0/24"]
    private_cidr_block = ["192.168.4.0/24" , "192.168.5.0/24" , "192.168.6.0/24"]
    azs = ["us-west-2a" , "us-west-2b" , "us-west-2c"]
    tags = {
        Owner = "dev-team"
    }
}