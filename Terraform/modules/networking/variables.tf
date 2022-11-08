# Variables
variable "access_key" {
  default = "ACCESS_KEY_HERE"
}
variable "secret_key" {
  default = "SECRET_KEY_HERE"
}

variable "aws_key_path" {
  default  = "/home/himanshu/eskey.pem"
}
variable "aws_key_name" {
}

variable "aws_region" {
  type        = string
  description = "AWS Region the instance is launched in"
  default     = "ap-south-1"
}

variable "ProjectName" {
  type = string
  description = "Project Name"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default = "10.0.0.0/16"
}


variable "public_subnets" {
  description = "Public Subnet "
  type = list(string)

}

variable "private_subnets" {
  description = "Private Subnet"
  type = list(string)

}

variable "db_private_subnets" {
  description = "DB Private Subnet"
  type = list(string)

}


variable "tags" {
  description = "Provide the tags"
  type = list(string)
  default = ["1","2","3"]
}
