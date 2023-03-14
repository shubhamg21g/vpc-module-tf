variable "appname" {
    type = string
}

variable "env" {
    type = string
}

variable "tags" {
    type = map(string)
    default = {}
}