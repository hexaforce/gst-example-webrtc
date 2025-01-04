variable "domain" {
  description = "The domain name for Route53 and ACM"
  type        = string
}

data "aws_route53_zone" "hexaforce-io" {
  name = var.domain
}

resource "aws_acm_certificate" "hexaforce-io" {
  domain_name       = "*.${var.domain}"
  validation_method = "DNS"
}

resource "aws_route53_record" "gst-webrtc-api-demo" {
  alias {
    evaluate_target_health = true
    name                   = aws_lb.gstreamer-loadbalancer.dns_name
    zone_id                = aws_lb.gstreamer-loadbalancer.zone_id
  }

  name    = "gst-webrtc-api-demo.${var.domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.hexaforce-io.zone_id
}

resource "aws_route53_record" "gst-webrtc-signalling-server" {
  alias {
    evaluate_target_health = true
    name                   = aws_lb.gstreamer-loadbalancer.dns_name
    zone_id                = aws_lb.gstreamer-loadbalancer.zone_id
  }

  name    = "gst-webrtc-signalling-server.${var.domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.hexaforce-io.zone_id
}

resource "aws_route53_record" "gst-examples-js" {
  alias {
    evaluate_target_health = true
    name                   = aws_lb.gstreamer-loadbalancer.dns_name
    zone_id                = aws_lb.gstreamer-loadbalancer.zone_id
  }

  name    = "gst-examples-js.${var.domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.hexaforce-io.zone_id
}

resource "aws_route53_record" "gst-examples-signalling" {
  alias {
    evaluate_target_health = true
    name                   = aws_lb.gstreamer-loadbalancer.dns_name
    zone_id                = aws_lb.gstreamer-loadbalancer.zone_id
  }

  name    = "gst-examples-signalling.${var.domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.hexaforce-io.zone_id
}

resource "aws_route53_record" "turn" {
  records = [aws_instance.gstreamer-demo-instance.public_ip]

  name    = "turn.${var.domain}"
  type    = "A"
  ttl     = 300
  zone_id = data.aws_route53_zone.hexaforce-io.zone_id
}
