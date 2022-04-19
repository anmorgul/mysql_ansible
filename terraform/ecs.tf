resource "aws_ecr_repository" "petclinic" {
  name = "petclinic_ecr_repo"
  tags = {
    Name = "petclinic_ecr_repo"
  }
}

resource "aws_ecs_cluster" "petclinic" {
  name = "petclinic_ecs_claster"
  tags = {
    Name = "petclinic_ecs_claster"
  }
}

resource "aws_ecs_task_definition" "petclinic" {
  family                = "petclinic_task"
  container_definitions = <<DEFINITION
  [
    {
      "name": "petclinic-container",
      "image": "${aws_ecr_repository.petclinic.repository_url}:latest",
      "entryPoint": [],
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],dd
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
    Name = "petclinic-ecs-td"

  }
}

data "aws_ecs_task_definition" "app_petclinic" {
  task_definition = aws_ecs_task_definition.petclinic.family
}

resource "aws_ecs_service" "aws_ecs_service" {
  name                 = "petclinic-ecs-service"
  cluster              = aws_ecs_cluster.petclinic.id
  task_definition      = "${aws_ecs_task_definition.petclinic.family}:${max(aws_ecs_task_definition.petclinic.revision, data.aws_ecs_task_definition.app_petclinic.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  #   network_configuration {
  #     subnets          = aws_subnet.public.*.id
  #     #private
  #     assign_public_ip = true
  #     #false
  #     security_groups = [
  #       aws_security_group.service_security_group.id,
  #       aws_security_group.load_balancer_security_group.id
  #     ]
}