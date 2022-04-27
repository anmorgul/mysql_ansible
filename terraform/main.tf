provider "aws" {
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
  region = var.aws_region
}

# links to keys
data "template_file" "db_public_key" {
  template = file("${var.db_public_key_path}")
}

data "template_file" "bastion_public_key" {
  template = file("${var.bastion_public_key_path}")
}

# Save Keys pairs
resource "aws_key_pair" "db" {
  key_name   = var.db_public_key_name
  public_key = data.template_file.db_public_key.rendered
}

resource "aws_key_pair" "bastion" {
  key_name   = var.bastion_public_key_name
  public_key = data.template_file.bastion_public_key.rendered
}

# Virtual Private Cloud
resource "aws_vpc" "petclinic" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.app_name}_vpc"
  }
}

# SG for ping
resource "aws_security_group" "ping" {
  vpc_id      = aws_vpc.petclinic.id
  name        = "allow_ping"
  description = "Allow ping"
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for ssh bastion
resource "aws_security_group" "ssh_access_public" {
  vpc_id      = aws_vpc.petclinic.id
  name        = "allow_ssh_traffic_public"
  description = "Allow ssh traffic public"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.app_name}_allow_ssh_traffic_public"
  }
}

# Security group for ssh db
resource "aws_security_group" "ssh_access_db" {
  vpc_id      = aws_vpc.petclinic.id
  name        = "allow_ssh_traffic_db"
  description = "Allow ssh traffic db"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.app_name}_allow_ssh_traffic_db"
  }
}
# Security group for mysql traffic
resource "aws_security_group" "db_traffic" {
  vpc_id      = aws_vpc.petclinic.id
  name        = "allow_mysql_traffic"
  description = "Allow mysql traffic"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.app_name}_allow_mysql_traffic"
  }
}

# Security group for web traffic
resource "aws_security_group" "web_traffic" {
  vpc_id      = aws_vpc.petclinic.id
  name        = "allow_web_traffic"
  description = "Allow web traffic"
  dynamic "ingress" {
    for_each = var.ingress_web
    content {
      description = ingress.key
      from_port   = ingress.value.port_from
      to_port     = ingress.value.port_to
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.app_name}_allow_web_traffic"
  }
}

# Subnet
resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.petclinic.id
  cidr_block        = var.db_subnet_cidr_block
  availability_zone = var.availability_zone_a
  tags = {
    Name = "${var.app_name}_db_subnet"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.petclinic.id
  cidr_block              = var.public_subnet_a_cidr_block
  availability_zone       = var.availability_zone_a
  # map_public_ip_on_launch = true
  tags = {
    Name = "${var.app_name}_public_subnet_a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.petclinic.id
  cidr_block              = var.public_subnet_b_cidr_block
  availability_zone       = var.availability_zone_b
  # map_public_ip_on_launch = true
  tags = {
    Name = "${var.app_name}_public_subnet_b"
  }
}


# Internet gateway
resource "aws_internet_gateway" "petclinic" {
  vpc_id = aws_vpc.petclinic.id
  tags = {
    Name = "${var.app_name}_gw"
  }
}

resource "aws_nat_gateway" "db" {
  allocation_id = aws_eip.db.id
  subnet_id     = aws_subnet.public_a.id
  # connectivity_type = "private"
  # subnet_id         = aws_subnet.db.id
}

# Route table
resource "aws_route_table" "petclinic" {
  vpc_id = aws_vpc.petclinic.id
  tags = {
    Name = "${var.app_name}_route_table"
  }
}

resource "aws_route_table" "privat" {
  vpc_id = aws_vpc.petclinic.id
  tags = {
    Name = "${var.app_name}_privat_route_table"
  }
}

# Route table association
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.petclinic.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.petclinic.id
}
resource "aws_route_table_association" "db" {
  subnet_id      = aws_subnet.db.id
  route_table_id = aws_route_table.privat.id
}

# Route
resource "aws_route" "db" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.privat.id
  # gateway_id             = aws_internet_gateway.petclinic.id
  gateway_id             = aws_nat_gateway.db.id
}

resource "aws_route" "public_a" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.petclinic.id
  gateway_id             = aws_internet_gateway.petclinic.id
}

resource "aws_route" "public_b" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.petclinic.id
  gateway_id             = aws_internet_gateway.petclinic.id
}

# # Network interface
# resource "aws_network_interface" "db" {
#   subnet_id       = aws_subnet.db.id
#   private_ips     = [var.db_private_ips]
#   security_groups = [aws_security_group.db_traffic.id, aws_security_group.ssh_access_db.id, aws_security_group.ping.id]
#   tags = {
#     Name = "db_primary_network_interface"
#   }
# }

# Elasic IP
resource "aws_eip" "db" {
  # instance = aws_instance.db.id
  # network_interface = aws_network_interface.db.id
  vpc               = true
}

# Most recent ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# bastion
resource "aws_launch_configuration" "bastion" {
  name            = "launch_configuration_for_bastion"
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.ssh_access_public.id, aws_security_group.ping.id]
  key_name        = var.bastion_public_key_name
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion" {
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  # availability_zones   = [var.availability_zone_a, var.availability_zone_b]
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  launch_configuration = aws_launch_configuration.bastion.name
  depends_on = [
    aws_launch_configuration.bastion,
  ]
}

# EC2 instance for mysql

resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  private_ip             = var.db_private_ips
  key_name               = var.db_public_key_name
  vpc_security_group_ids = [aws_security_group.db_traffic.id, aws_security_group.ssh_access_db.id, aws_security_group.ping.id]
  subnet_id              = aws_subnet.db.id
  # network_interface {
  #   network_interface_id = aws_network_interface.db.id
  #   device_index         = 0
  # }
  depends_on = [aws_internet_gateway.petclinic]
  tags = {
    Name = "db_instance"
  }
}

############
resource "aws_ecr_repository" "petclinic" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = "${var.app_name}_ecr"
  }
}

resource "aws_ecs_cluster" "petclinic" {
  name = "petclinic_ecs_claster"
  tags = {
    Name = "petclinic_ecs_claster"
  }
}


data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.app_name}_execution_task_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name = "${var.app_name}_iam_role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#      "environment": ${jsonencode(var.task_envs)},
resource "aws_ecs_task_definition" "petclinic" {
  family = "petclinic_task"
  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.app_name}_container",
      "image": "${aws_ecr_repository.petclinic.repository_url}:latest",
      "entryPoint": [],
      "essential": true,

      "environment": ${jsonencode(var.task_envs)},
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_execution.arn

  tags = {
    Name = "petclinic_ecs_td"

  }
}

data "aws_ecs_task_definition" "app_petclinic" {
  task_definition = aws_ecs_task_definition.petclinic.family
}

resource "aws_ecs_service" "petclinic" {
  name                 = "petclinic_ecs_service"
  cluster              = aws_ecs_cluster.petclinic.id
  task_definition      = "${aws_ecs_task_definition.petclinic.family}:${max(aws_ecs_task_definition.petclinic.revision, data.aws_ecs_task_definition.app_petclinic.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 0
  force_new_deployment = true
  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.web_traffic.id,
      aws_security_group.ping.id,
    ]
    subnets = [
      # aws_subnet.db.id,
      aws_subnet.public_a.id,
      aws_subnet.public_b.id,
    ]
  }
}
