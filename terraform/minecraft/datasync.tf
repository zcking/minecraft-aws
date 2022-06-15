/*
Uses AWS Data Sync to synchronize data between EFS and S3
for configuring and managing the minecraft server / game data
*/

data "aws_iam_policy_document" "datasync-assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "datasync.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:datasync:${var.region}:${var.account}:*"]
    }
  }
}

data "aws_iam_policy_document" "datasync-policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [
      var.s3_bucket_arn
    ]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging",
      "s3:PutObject"
    ]
    resources = [
      "${var.s3_bucket_arn}/*"
    ]
  }
  statement {
    actions = [
      "cloudwatch:*"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "datasync" {
  name_prefix        = "datasync-minecraft"
  assume_role_policy = data.aws_iam_policy_document.datasync-assume-role-policy.json
}

resource "aws_iam_role_policy" "datasync" {
  name_prefix = "datasync-minecraft"
  role        = aws_iam_role.datasync.name
  policy      = data.aws_iam_policy_document.datasync-policy.json
}

resource "aws_datasync_location_efs" "minecraft" {
  efs_file_system_arn = aws_efs_mount_target.default.file_system_arn
  subdirectory        = "/minecraft"

  ec2_config {
    security_group_arns = [aws_security_group.minecraft-efs.arn]
    subnet_arn          = data.aws_subnet.default.arn
  }
}

resource "aws_datasync_location_s3" "minecraft" {
  s3_bucket_arn    = var.s3_bucket_arn
  subdirectory     = "/minecraft"
  s3_storage_class = "STANDARD"

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync.arn
  }
  depends_on = [
    aws_iam_role_policy.datasync
  ]
}

resource "aws_datasync_task" "minecraft-efs-to-s3" {
  name                     = "minecraft-efs-to-s3"
  source_location_arn      = aws_datasync_location_efs.minecraft.arn
  destination_location_arn = aws_datasync_location_s3.minecraft.arn
  options {
    transfer_mode          = "CHANGED"
    preserve_deleted_files = "PRESERVE"
  }
}

resource "aws_datasync_task" "minecraft-s3-to-efs" {
  name                     = "minecraft-s3-to-efs"
  source_location_arn      = aws_datasync_location_s3.minecraft.arn
  destination_location_arn = aws_datasync_location_efs.minecraft.arn
  options {
    transfer_mode          = "CHANGED"
    preserve_deleted_files = "PRESERVE"
    posix_permissions      = "NONE"
    uid                    = "NONE"
    gid                    = "NONE"
  }
}
