resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_route53_record" "ses_verification_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.main.id}"
  type    = "TXT"
  ttl     = "600"
  records = [
    aws_ses_domain_identity.main.verification_token
  ]
}

resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.main.zone_id
  name    = ""
  type    = "MX"
  ttl     = "300"
  records = [
    "10 inbound-smtp.${var.region}.amazonaws.com"
  ]
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
