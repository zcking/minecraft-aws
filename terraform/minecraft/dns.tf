resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_route53_record" "minecraft" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "minecraft"
  type    = "A"
  ttl     = "30"
  // irrelevant because this value will change every time the MC server launches
  records = ["1.1.1.1"]

  lifecycle {
    ignore_changes = [
      records
    ]
  }
}

// Setup for Route53 DNS query logging which is only available in
// us-east-1, hence the specific provider
resource "aws_cloudwatch_log_group" "route53-main" {
  provider          = aws.us-east-1
  name              = "/aws/route53/${aws_route53_zone.main.name}"
  retention_in_days = 1
}

// Cloudwatch log resource policy to allow Route53 to write logs
// to log groups under /aws/route53/*
data "aws_iam_policy_document" "route53-query-logging-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/route53/*"]
    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "route53-query-logging-policy" {
  provider = aws.us-east-1

  policy_document = data.aws_iam_policy_document.route53-query-logging-policy.json
  policy_name     = "route53-query-logging-policy"
}

resource "aws_route53_query_log" "main" {
  depends_on = [
    aws_cloudwatch_log_resource_policy.route53-query-logging-policy
  ]
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.route53-main.arn
  zone_id                  = aws_route53_zone.main.zone_id
}
