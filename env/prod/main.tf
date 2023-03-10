provider "aws" {
    profile = "terraform"
    region ="us-west-2"
}

module "vpc" {
    source = "../../modules/vpc"
    env = "production"
    vpc_cidr_block = "192.168.0.0/16"
    public_cidr_block = "192.168.1.0/24"
    private_cidr_block = "192.168.2.0/24"
    azs = "us-west-2a"  
}