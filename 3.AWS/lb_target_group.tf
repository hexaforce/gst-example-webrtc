resource "aws_lb_target_group" "gst-webrtc-api-demo" {
  deregistration_delay = 300

  health_check {
    enabled             = true
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = 200
    path                = "/health-check"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  name                              = "gst-webrtc-api-demo"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_anomaly_mitigation = "off"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  port                              = 80
  protocol                          = "HTTP"
  protocol_version                  = "HTTP1"
  slow_start                        = 0

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }

  target_group_health {
    dns_failover {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }

    unhealthy_state_routing {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }
  }

  target_type = "instance"
  vpc_id      = aws_vpc.gstreamer-vpc.id
}

resource "aws_lb_target_group_attachment" "gst-webrtc-api-demo" {
  target_group_arn = aws_lb_target_group.gst-webrtc-api-demo.arn
  target_id        = aws_instance.gstreamer-demo-instance.id
  port             = 13000
}

resource "aws_lb_target_group" "gst-webrtc-signalling-server" {
  deregistration_delay = 300

  health_check {
    enabled             = true
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = 200
    path                = "/health-check"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  name                              = "gst-webrtc-signalling-server"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_anomaly_mitigation = "off"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  port                              = 80
  protocol                          = "HTTP"
  protocol_version                  = "HTTP1"
  slow_start                        = 0

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }

  target_group_health {
    dns_failover {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }

    unhealthy_state_routing {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }
  }

  target_type = "instance"
  vpc_id      = aws_vpc.gstreamer-vpc.id
}

resource "aws_lb_target_group_attachment" "gst-webrtc-signalling-server" {
  target_group_arn = aws_lb_target_group.gst-webrtc-signalling-server.arn
  target_id        = aws_instance.gstreamer-demo-instance.id
  port             = 18443
}

resource "aws_lb_target_group" "gst-examples-js" {
  deregistration_delay = 300

  health_check {
    enabled             = true
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = 200
    path                = "/health-check"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  name                              = "gst-examples-js"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_anomaly_mitigation = "off"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  port                              = 80
  protocol                          = "HTTP"
  protocol_version                  = "HTTP1"
  slow_start                        = 0

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }

  target_group_health {
    dns_failover {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }

    unhealthy_state_routing {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }
  }

  target_type = "instance"
  vpc_id      = aws_vpc.gstreamer-vpc.id
}

resource "aws_lb_target_group_attachment" "gst-examples-js" {
  target_group_arn = aws_lb_target_group.gst-examples-js.arn
  target_id        = aws_instance.gstreamer-demo-instance.id
  port             = 3000
}

resource "aws_lb_target_group" "gst-examples-signalling" {
  deregistration_delay = 300

  health_check {
    enabled             = true
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = 200
    path                = "/health-check"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  name                              = "gst-examples-signalling"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_anomaly_mitigation = "off"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  port                              = 80
  protocol                          = "HTTP"
  protocol_version                  = "HTTP1"
  slow_start                        = 0

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }

  target_group_health {
    dns_failover {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }

    unhealthy_state_routing {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }
  }

  target_type = "instance"
  vpc_id      = aws_vpc.gstreamer-vpc.id
}

resource "aws_lb_target_group_attachment" "gst-examples-signalling" {
  target_group_arn = aws_lb_target_group.gst-examples-signalling.arn
  target_id        = aws_instance.gstreamer-demo-instance.id
  port             = 8443
}

resource "aws_lb_target_group" "gst-default" {
  deregistration_delay = 300

  health_check {
    enabled             = true
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = 200
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  name                              = "gst-default"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_anomaly_mitigation = "off"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  port                              = 80
  protocol                          = "HTTP"
  protocol_version                  = "HTTP1"
  slow_start                        = 0

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }

  target_group_health {
    dns_failover {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }

    unhealthy_state_routing {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }
  }

  target_type = "instance"
  vpc_id      = aws_vpc.gstreamer-vpc.id
}

resource "aws_lb_target_group_attachment" "gst-default" {
  target_group_arn = aws_lb_target_group.gst-default.arn
  target_id        = aws_instance.gstreamer-demo-instance.id
  port             = 80
}
