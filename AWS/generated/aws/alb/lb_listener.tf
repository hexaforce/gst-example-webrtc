resource "aws_lb_listener" "tfer--arn-003A-aws-003A-elasticloadbalancing-003A-ap-northeast-1-003A-412883365174-003A-listener-002F-app-002F-hexaforce-002F-b74ad437bc469a91-002F-d374b63e24cc2af0" {
  certificate_arn = "arn:aws:acm:ap-northeast-1:412883365174:certificate/d28b0f48-44d9-447f-a2f0-aad8380c24c8"

  default_action {
    forward {
      stickiness {
        duration = "0"
        enabled  = "false"
      }

      target_group {
        arn    = "arn:aws:elasticloadbalancing:ap-northeast-1:412883365174:targetgroup/webrtc/3e9cb24b0e7cf3f6"
        weight = "1"
      }
    }

    target_group_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:412883365174:targetgroup/webrtc/3e9cb24b0e7cf3f6"
    type             = "forward"
  }

  load_balancer_arn = "${data.terraform_remote_state.alb.outputs.aws_lb_tfer--hexaforce_id}"

  mutual_authentication {
    ignore_client_certificate_expiry = "false"
    mode                             = "off"
  }

  port       = "443"
  protocol   = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}
