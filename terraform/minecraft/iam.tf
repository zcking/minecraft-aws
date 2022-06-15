data "aws_iam_policy_document" "efs-policy" {
  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:DescribeFileSystems"
    ]
    resources = [
      aws_efs_file_system.minecraft.arn
    ]
    condition {
      test     = "StringEquals"
      variable = "elasticfilesystem:AccessPointArn"
      values = [
        aws_efs_access_point.minecraft.arn,
      ]
    }
  }
}

data "aws_iam_policy_document" "ecs-policy" {
  statement {
    actions = [
      "ecs:*"
    ]
    resources = [
      "arn:aws:ecs:${var.region}:${var.account}:service/${var.cluster_name}/${var.service_name}",
      "arn:aws:ecs:${var.region}:${var.account}:task/${var.cluster_name}/*"
    ]
  }

  statement {
    actions = [
      "ec2:DescribeNetworkInterfaces"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "route53-policy" {
  statement {
    actions = [
      "route53:GetHostedZone",
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = [
      # aws_route53_zone.minecraft.zone_id
      "*"
    ]
  }

  statement {
    actions = [
      "route53:ListHostedZones"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "sns-policy" {
  statement {
    actions = [
      "sns:Publish"
    ]
    resources = [
      aws_sns_topic.minecraft-notifications.arn
    ]
  }
}

data "aws_iam_policy_document" "ecs-assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "minecraft-policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.efs-policy.json,
    data.aws_iam_policy_document.ecs-policy.json,
    data.aws_iam_policy_document.route53-policy.json,
    data.aws_iam_policy_document.sns-policy.json
  ]
}

// Now the IAM role that our minecraft ECS will use
resource "aws_iam_role" "minecraft" {
  name_prefix        = "minecraft"
  assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
}

resource "aws_iam_role_policy" "minecraft" {
  name_prefix = "minecraft"
  role        = aws_iam_role.minecraft.id
  policy      = data.aws_iam_policy_document.minecraft-policy.json
}
