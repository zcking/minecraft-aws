locals {
  default_minecraft_server_env_vars = { "EULA" = "TRUE" }
  minecraft_server_env_vars = merge(
    var.extra_minecraft_server_env_vars,
    local.default_minecraft_server_env_vars
  )
  _minecraft_server_environment = [
    for k, v in local.minecraft_server_env_vars :
    { name = k, value = v }
  ]

}
resource "aws_ecs_task_definition" "minecraft-server" {
  family                   = "minecraft-server"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.minecraft_server_cpu
  memory                   = var.minecraft_server_memory
  task_role_arn            = aws_iam_role.minecraft.arn

  container_definitions = jsonencode([
    // minecraft server container
    {
      name      = "minecraft-server"
      image     = "itzg/minecraft-server"
      cpu       = var.minecraft_server_cpu
      memory    = var.minecraft_server_memory
      essential = false
      portMappings = [
        {
          containerPort = 25565
          hostPort      = 25565
        }
      ]
      environment = local._minecraft_server_environment
      mountPoints = [
        {
          sourceVolume  = "data"
          containerPath = "/data"
        }
      ]
    },

    // watchdog container
    {
      name      = "minecraft-ecsfargate-watchdog"
      image     = "doctorray/minecraft-ecsfargate-watchdog"
      essential = true
      environment = [
        {
          name  = "CLUSTER"
          value = var.cluster_name
        },
        {
          name  = "SERVICE",
          value = var.service_name
        },
        {
          name  = "DNSZONE",
          value = local.zone_id
        },
        {
          name  = "SERVERNAME",
          value = "minecraft.${var.domain_name}"
        },
        {
          name  = "SHUTDOWNMIN",
          value = "15"
        },
        {
          name  = "SNSTOPIC",
          value = aws_sns_topic.minecraft-notifications.arn
        }
      ]
    }
  ])

  // Mount EFS volume for persisting game data
  volume {
    name = "data"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.minecraft.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config {
        access_point_id = aws_efs_access_point.minecraft.id
        iam             = "ENABLED"
      }
    }
  }
}
