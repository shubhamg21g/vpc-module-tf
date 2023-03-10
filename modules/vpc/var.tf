variable "vpc_cidr_block" {
    type = string
}

variable "public_cidr_block" {
  type = list
}

variable "private_cidr_block" {
    type = list
}

variable "azs" {
    type = list(string)
}

variable "env" {
    type = string
}

variable "appname" {
    type = string
}

variable "tags" {
    type = map(string)
}
