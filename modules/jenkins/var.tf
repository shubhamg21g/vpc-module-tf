variable "appname" {
  type = string
}

variable "env" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = set(string)
}