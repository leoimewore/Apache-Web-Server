resource "aws_route53_zone" "primary" {
  name = "capeng.info"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.capeng.info"
  type    = "A"

  alias {
    name                   = var.dns_name
    zone_id                = var.hosted_zone
    evaluate_target_health = true
  }
}