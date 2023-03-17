data "aws_iam_policy_document" "lambda-assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "minecraft-lambda" {
  name_prefix        = "minecraft"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role-policy.json
}

resource "aws_iam_role_policy" "minecraft-lambda" {
  name_prefix = "minecraftlambda"
  role        = aws_iam_role.minecraft-lambda.id
  policy      = data.aws_iam_policy_document.ecs-policy.json
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "/tmp/lambda.zip"
  source_file = "${path.module}/../../lambda/lambda_function.py"
}

resource "aws_lambda_function" "minecraft-launcher" {
  provider         = aws.us-east-1
  function_name    = "minecraft-launcher"
  role             = aws_iam_role.minecraft-lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      REGION  = var.region
      CLUSTER = var.cluster_name
      SERVICE = var.service_name
    }
  }
}

// Allow SES to invoke the lambda function (upon receiving email)
resource "aws_lambda_permission" "ses-permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.minecraft-launcher.function_name
  principal     = "ses.amazonaws.com"
  source_arn    = "arn:aws:ses:${var.region}:${var.account}:receipt-rule-set/*"
}
