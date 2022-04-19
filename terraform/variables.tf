variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-central-1"
}

variable "instance_type" {
  type        = string
  description = "Type of instance"
  default     = "t2.micro"
}

variable "app_name" {
  type    = string
  default = "My_app"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnet_cidr_block" {
  type    = string
  default = "10.10.10.0/24"
}

variable "availability_zone" {
  type    = string
  default = "eu-central-1a"
}

variable "mymysql_private_ips" {
  type    = string
  default = "10.10.10.100"
}

variable "mymysql_public_key_path" {
  type    = string
  default = "../secrets/awsmysqlserver/id_rsa_awsmymysql.pub"
}

variable "mymysql_public_key_name" {
  type    = string
  default = "mymysql"
}