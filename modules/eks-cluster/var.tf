variable "appname" {
  type = string
}

variable "env" {
  type = string
}

variable "aws_public_subnet" {}

variable "vpc_id" {}

variable "endpoint_private_access" {}

variable "endpoint_public_access" {}

variable "public_access_cidrs" {}

variable "node_group_name" {}

variable "scaling_desired_size" {}

variable "scaling_max_size" {}

variable "scaling_min_size" {}

variable "instance_types" {}

variable "key_pair" {}

variable "security_group_ids" {}