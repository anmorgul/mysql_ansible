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
  default = "my_petclinic"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "db_subnet_cidr_block" {
  type    = string
  default = "10.10.10.0/24"
}

variable "public_subnet_a_cidr_block" {
  type    = string
  default = "10.10.11.0/24"
}

variable "public_subnet_b_cidr_block" {
  type    = string
  default = "10.10.12.0/24"
}

variable "availability_zone_a" {
  type    = string
  default = "eu-central-1a"
}

variable "availability_zone_b" {
  type    = string
  default = "eu-central-1b"
}

variable "db_private_ips" {
  type    = string
  default = "10.10.10.100"
}

variable "db_public_key_path" {
  type    = string
  default = "../secrets/awsmysqlserver/id_rsa_db.pub"
}

variable "db_public_key_name" {
  type    = string
  default = "db"
}

variable "bastion_public_key_path" {
  type    = string
  default = "../secrets/bastion/id_rsa_bastion.pub"
}

variable "bastion_public_key_name" {
  type    = string
  default = "bastion"
}

variable "ingress_web" {
  type = map(any)
  default = {
    "80" = {
      port_from   = 80,
      port_to     = 8080,
      cidr_blocks = ["0.0.0.0/0"],
    }
    "8080" = {
      port_from   = 8080,
      port_to     = 8080,
      cidr_blocks = ["0.0.0.0/0"],
    }
  }
}

variable "task_envs" {
}
