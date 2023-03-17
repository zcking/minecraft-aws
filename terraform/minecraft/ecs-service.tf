resource "aws_ecs_service" "minecraft-server" {
  name            = "minecraft-server"
  cluster         = aws_ecs_cluster.minecraft.id
  task_definition = aws_ecs_task_definition.minecraft-server.arn
  desired_count   = 0
  # iam_role        = aws_iam_role.minecraft.arn
  depends_on = [
    aws_iam_role.minecraft
  ]
  launch_type      = "FARGATE"
  platform_version = "LATEST"

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

resource "aws_security_group" "minecraft-server" {
  name_prefix = "minecraft-server"
  ingress {
    protocol  = "tcp"
    from_port = 25565
    to_port   = 25565
    cidr_blocks = [
      # "107.122.96.147/32",
      # "166.205.140.81/32",
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
