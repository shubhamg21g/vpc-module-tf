variable "appname" {
  type = string
}

variable "env" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "security_groups" {
  type = set(string)
}

variable "subnets" {
  type = list(string)
}

variable "vpc_zone_identifier" {
  type = list(string)
}

variable "user_data_base64" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "policy_type" {
  type = string

}