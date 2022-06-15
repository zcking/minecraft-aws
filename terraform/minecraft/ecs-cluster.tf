resource "aws_ecs_cluster" "minecraft" {
  name = "minecraft"
}

resource "aws_ecs_cluster_capacity_providers" "minecraft" {
  cluster_name       = aws_ecs_cluster.minecraft.name
  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}
