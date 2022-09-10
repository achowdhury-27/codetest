variable "region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t3a.micro"
}

variable "aws_ami" {
  default = "ami-0aa108435"
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "azs" {
   type = list(string)
   default = ["us-east-1a","us-east-1b"]
}

