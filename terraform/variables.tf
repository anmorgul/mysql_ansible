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
  default = "petclinic"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "mymysql_subnet_cidr_block" {
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
  default = [
    {
      "name": "MYSQL_USER",
      "value": "petclinic"
    },
    {
      "name": "MYSQL_PASSWORD",
      "value": "petclinic"
    },
    {
      "name": "MYSQL_URL",
      "value": "jdbc:mysql://localhost/petclinic"
    }
  ]
}
