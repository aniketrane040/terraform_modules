variable "ami_id" {
  type    = string
  default = "ami-0e00969c7085e27c4"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "subnet-id" {
  type    = string
  default = "subnet-01d1d2f885ccbf92b"
}

variable "parameter_for_vpc" {
  type    = string
  default = "/ops/vpc"
}

variable "vpc-id" {
  type    = string
  default = "vpc-05ef949b5741194b8"
}

variable "key_name" {
  type    = string
  default = "jenkins_key"
}

variable "ssh_access_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "web_access_cidr" {
  type    = string
  default = "0.0.0.0/0"
}