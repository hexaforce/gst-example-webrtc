resource "aws_lb" "gstreamer-loadbalancer" {
  client_keep_alive = 3600

  desync_mitigation_mode                      = "defensive"
  drop_invalid_header_fields                  = false
  enable_cross_zone_load_balancing            = true
  enable_deletion_protection                  = false
  enable_http2                                = true
  enable_tls_version_and_cipher_suite_headers = false
  enable_waf_fail_open                        = false
  enable_xff_client_port                      = false
  enable_zonal_shift                          = false
  idle_timeout                                = 60
  internal                                    = false
  ip_address_type                             = "ipv4"
  load_balancer_type                          = "application"
  name                                        = "gstreamer-loadbalancer"
  preserve_host_header                        = false
  security_groups                             = [aws_security_group.gstreamer-sg-alb.id]

  subnets = [aws_subnet.gstreamer-subnet-1c.id, aws_subnet.gstreamer-subnet-1a.id]
  
  xff_header_processing_mode = "append"
}

resource "aws_lb_listener" "gstreamer-listener" {
  certificate_arn = aws_acm_certificate.hexaforce-io.arn

  default_action {
    forward {
      stickiness {
        duration = 1
        enabled  = false
      }

      target_group {
        arn    = aws_lb_target_group.gst-default.id
        weight = 5
      }
    }

    target_group_arn = aws_lb_target_group.gst-default.id
    type             = "forward"
  }

  load_balancer_arn = aws_lb.gstreamer-loadbalancer.id

  mutual_authentication {
    ignore_client_certificate_expiry = false
    mode                             = "off"
  }

  port       = 443
  protocol   = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

resource "aws_lb_listener_rule" "gst-webrtc-api-demo" {
  action {
    forward {
      stickiness {
        duration = 3600
        enabled  = false
      }

      target_group {
        arn    = aws_lb_target_group.gst-webrtc-api-demo.arn
        weight = 1
      }
    }

    order            = 1
    target_group_arn = aws_lb_target_group.gst-webrtc-api-demo.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = [aws_route53_record.gst-webrtc-api-demo.name]
    }
  }

  listener_arn = aws_lb_listener.gstreamer-listener.arn
  priority     = 1

  tags = {
    Name = aws_route53_record.gst-webrtc-api-demo.name
  }

  tags_all = {
    Name = aws_route53_record.gst-webrtc-api-demo.name
  }
}

resource "aws_lb_listener_rule" "gst-webrtc-signalling-server" {
  action {
    forward {
      stickiness {
        duration = 3600
        enabled  = false
      }

      target_group {
        arn    = aws_lb_target_group.gst-webrtc-signalling-server.arn
        weight = 1
      }
    }

    order            = 1
    target_group_arn = aws_lb_target_group.gst-webrtc-signalling-server.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = [aws_route53_record.gst-webrtc-signalling-server.name]
    }
  }

  listener_arn = aws_lb_listener.gstreamer-listener.arn
  priority     = 2

  tags = {
    Name = aws_route53_record.gst-webrtc-signalling-server.name
  }

  tags_all = {
    Name = aws_route53_record.gst-webrtc-signalling-server.name
  }
}


resource "aws_lb_listener_rule" "gst-examples-js" {
  action {
    forward {
      stickiness {
        duration = 3600
        enabled  = false
      }

      target_group {
        arn    = aws_lb_target_group.gst-examples-js.arn
        weight = 1
      }
    }

    order            = 1
    target_group_arn = aws_lb_target_group.gst-examples-js.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = [aws_route53_record.gst-examples-js.name]
    }
  }

  listener_arn = aws_lb_listener.gstreamer-listener.arn
  priority     = 3

  tags = {
    Name = aws_route53_record.gst-examples-js.name
  }

  tags_all = {
    Name = aws_route53_record.gst-examples-js.name
  }
}

resource "aws_lb_listener_rule" "gst-examples-signalling" {
  action {
    forward {
      stickiness {
        duration = 3600
        enabled  = false
      }

      target_group {
        arn    = aws_lb_target_group.gst-examples-signalling.arn
        weight = 1
      }
    }

    order            = 1
    target_group_arn = aws_lb_target_group.gst-examples-signalling.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = [aws_route53_record.gst-examples-signalling.name]
    }
  }

  listener_arn = aws_lb_listener.gstreamer-listener.arn
  priority     = 4

  tags = {
    Name = aws_route53_record.gst-examples-signalling.name
  }

  tags_all = {
    Name = aws_route53_record.gst-examples-signalling.name
  }
}
