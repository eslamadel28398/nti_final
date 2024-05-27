variable "cidr_block" {
  type = string
}

variable "region" {
  type = string
}
variable "sub1_cidr" {
  type = string
}
variable "sub2_cidr" {
  type = string
}
variable "az1" {
  type = string
}
variable "az2" {
  type = string
}

variable "rt_cidr" {
  type =  string
}

variable "workers_desired" {
  type = string
}
variable "workers_max" {
  type = string
}
variable "workers_min" {
  type = string
}
variable "max_unavailable" {
  type = string
}
variable "instance_types" {
  type = string
}