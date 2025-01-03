resource "aws_lb_listener_rule" "tfer--arn-003A-aws-003A-elasticloadbalancing-003A-ap-northeast-1-003A-412883365174-003A-listener-rule-002F-app-002F-hexaforce-002F-b74ad437bc469a91-002F-d374b63e24cc2af0-002F-01b34ac786d95d63" {
  action {
    forward {
      stickiness {
        duration = "3600"
        enabled  = "false"
      }

      target_group {
        arn    = "arn:aws:elasticloadbalancing:ap-northeast-1:412883365174:targetgroup/gst-webrtc-api/56c243d38b435262"
        weight = "1"
      }
    }

    order            = "1"
    target_group_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:412883365174:targetgroup/gst-webrtc-api/56c243d38b435262"
    type             = "forward"
  }

  condition {
    host_header {
      values = ["gst-webrtc-api.hexaforce.io"]
    }
  }

  listener_arn = "${data.terraform_remote_state.alb.outputs.aws_lb_listener_tfer--arn-003A-aws-003A-elasticloadbalancing-003A-ap-northeast-1-003A-412883365174-003A-listener-002F-app-002F-hexaforce-002F-b74ad437bc469a91-002F-d374b63e24cc2af0_id}"
  priority     = "1"

  tags = {
    Name = "gst-webrtc-api.hexaforce.io"
  }

  tags_all = {
    Name = "gst-webrtc-api.hexaforce.io"
  }
}

resource "aws_lb_listener_rule" "tfer--arn-003A-aws-003A-elasticloadbalancing-003A-ap-northeast-1-003A-412883365174-003A-listener-rule-002F-app-002F-hexaforce-002F-b74ad437bc469a91-002F-d374b63e24cc2af0-002F-d85b2682b81ef490" {
  action {
    forward {
      stickiness {
        duration = "3600"
        enabled  = "false"
      }

      target_group {
        arn    = "arn:aws:elasticloadbalancing:ap-northeast-1:412883365174:targetgroup/gst-webrtc-signalling-server/63ed767de5b37ddc"
        weight = "1"
      }
    }

    order            = "1"
    target_group_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:412883365174:targetgroup/gst-webrtc-signalling-server/63ed767de5b37ddc"
    type             = "forward"
  }

  condition {
    host_header {
      values = ["gst-webrtc-signalling-server.hexaforce.io"]
    }
  }

  listener_arn = "${data.terraform_remote_state.alb.outputs.aws_lb_listener_tfer--arn-003A-aws-003A-elasticloadbalancing-003A-ap-northeast-1-003A-412883365174-003A-listener-002F-app-002F-hexaforce-002F-b74ad437bc469a91-002F-d374b63e24cc2af0_id}"
  priority     = "2"

  tags = {
    Name = "gst-webrtc-signalling-server.hexaforce.io"
  }

  tags_all = {
    Name = "gst-webrtc-signalling-server.hexaforce.io"
  }
}

resource "aws_lb_listener_rule" "tfer--arn-003A-aws-003A-elasticloadbalancing-003A-ap-northeast-1-003A-412883365174-003A-listener-rule-002F-app-002F-hexaforce-002F-b74ad437bc469a91-002F-d374b63e24cc2af0-002F-fd877a526b5f20b5" {
  action {
    forward {
      stickiness {
        duration = "3600"
        enabled  = "false"
      }

      target_group {
        arn    = "arn:aws:elasticloadbalancing:ap-northeast-1:412883365174:targetgroup/signalling/e3241fd5c2133049"
        weight = "1"
      }
    }

    order            = "1"
    target_group_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:412883365174:targetgroup/signalling/e3241fd5c2133049"
    type             = "forward"
  }

  condition {
    host_header {
      values = ["signalling.hexaforce.io"]
    }
  }

  listener_arn = "${data.terraform_remote_state.alb.outputs.aws_lb_listener_tfer--arn-003A-aws-003A-elasticloadbalancing-003A-ap-northeast-1-003A-412883365174-003A-listener-002F-app-002F-hexaforce-002F-b74ad437bc469a91-002F-d374b63e24cc2af0_id}"
  priority     = "3"

  tags = {
    Name = "signalling.hexaforce.io"
  }

  tags_all = {
    Name = "signalling.hexaforce.io"
  }
}
