resource "aws_ecs_service" "minecraft-server" {
  name            = "minecraft-server"
  cluster         = aws_ecs_cluster.minecraft.id
  task_definition = aws_ecs_task_definition.minecraft-server.arn
  desired_count   = 0
  depends_on = [
    aws_iam_role.minecraft
  ]
  enable_execute_command = var.ecs_service_enable_execute_command
  launch_type            = "FARGATE"
  platform_version       = "LATEST"

  network_configuration {
    assign_public_ip = true
    subnets = [
      data.aws_subnet.default.id
    ]
    security_groups = [
      aws_security_group.minecraft-server.id
    ]
  }

  # In case we want to apply terraform changes while the server is up
  # ignore the desired_count attribute
  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

locals {
  default_ingresses = [
    {
      protocol  = "tcp"
      from_port = 25565
      to_port   = 25565
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  _ingresses = concat(local.default_ingresses, var.extra_ingresses)
}
resource "aws_security_group" "minecraft-server" {
  name_prefix = "minecraft-server"

  dynamic "ingress" {
    for_each = local._ingresses
    content {
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
