resource "aws_ses_domain_identity" "main" {
  domain = var.domain_name
}

resource "aws_ses_domain_identity_verification" "main" {
  domain = aws_ses_domain_identity.main.id
  depends_on = [
    aws_route53_record.ses_verification_record
  ]
}

resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
}

resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "primary-rules"
}

resource "aws_ses_receipt_rule" "minecraft" {
  name          = "minecraft-start"
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  recipients = [
    "minecraft-start@${var.domain_name}"
  ]
  enabled      = true
  scan_enabled = true

  lambda_action {
    function_arn = aws_lambda_function.minecraft-launcher.arn
    position     = 1
  }
}
