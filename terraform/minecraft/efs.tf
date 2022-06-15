/*
Creates an Elastic File System (EFS) and Access Point
at /minecraft for persisting game data.

Also creates a security group for this EFS so it can
later be mounted to the ECS task running in the same VPC.
*/

resource "aws_efs_file_system" "minecraft" {}

resource "aws_efs_access_point" "minecraft" {
  file_system_id = aws_efs_file_system.minecraft.id
  root_directory {
    path = "/minecraft"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }
  }
  posix_user {
    uid = 1000
    gid = 1000
  }
}

resource "aws_efs_mount_target" "default" {
  file_system_id  = aws_efs_file_system.minecraft.id
  subnet_id       = data.aws_subnet.default.id
  security_groups = [aws_security_group.minecraft-efs.id]
}

resource "aws_security_group" "minecraft-efs" {
  name        = "minecraft-efs"
  description = "Allow NFS to minecraft mount"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 2049 // NFS port
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
