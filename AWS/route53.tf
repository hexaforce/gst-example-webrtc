
data "aws_route53_zone" "hexaforce-io" {
  name = "hexaforce.io"
}

resource "aws_acm_certificate" "hexaforce-io" {
  domain_name       = "*.hexaforce.io"
  validation_method = "DNS"
}

resource "aws_route53_record" "gst-webrtc-api-demo" {
  alias {
    evaluate_target_health = true
    name                   = aws_lb.gstreamer-loadbalancer.dns_name
    zone_id                = aws_lb.gstreamer-loadbalancer.zone_id
  }

  name    = "gst-webrtc-api-demo.hexaforce.io"
  type    = "A"
  zone_id = data.aws_route53_zone.hexaforce-io.zone_id
}

resource "aws_route53_record" "gst-webrtc-signalling-server" {
  alias {
    evaluate_target_health = true
    name                   = aws_lb.gstreamer-loadbalancer.dns_name
    zone_id                = aws_lb.gstreamer-loadbalancer.zone_id
  }

  name    = "gst-webrtc-signalling-server.hexaforce.io"
  type    = "A"
  zone_id = data.aws_route53_zone.hexaforce-io.zone_id
}

resource "aws_route53_record" "gst-examples-js" {
  alias {
    evaluate_target_health = true
    name                   = aws_lb.gstreamer-loadbalancer.dns_name
    zone_id                = aws_lb.gstreamer-loadbalancer.zone_id
  }

  name    = "gst-examples-js.hexaforce.io"
  type    = "A"
  zone_id = data.aws_route53_zone.hexaforce-io.zone_id
}

resource "aws_route53_record" "gst-examples-signalling" {
  alias {
    evaluate_target_health = true
    name                   = aws_lb.gstreamer-loadbalancer.dns_name
    zone_id                = aws_lb.gstreamer-loadbalancer.zone_id
  }

  name    = "gst-examples-signalling.hexaforce.io"
  type    = "A"
  zone_id = data.aws_route53_zone.hexaforce-io.zone_id
}
