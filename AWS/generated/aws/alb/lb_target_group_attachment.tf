resource "aws_lb_target_group_attachment" "tfer--arn-003A-aws-003A-elasticloadbalancing-003A-ap-northeast-1-003A-412883365174-003A-targetgroup-002F-signalling-002F-e3241fd5c2133049-i-024af2adfe13f3775" {
  target_group_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:412883365174:targetgroup/signalling/e3241fd5c2133049"
  target_id        = "i-024af2adfe13f3775"
}

resource "aws_lb_target_group_attachment" "tfer--arn-003A-aws-003A-elasticloadbalancing-003A-ap-northeast-1-003A-412883365174-003A-targetgroup-002F-webrtc-002F-3e9cb24b0e7cf3f6-i-024af2adfe13f3775" {
  target_group_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:412883365174:targetgroup/webrtc/3e9cb24b0e7cf3f6"
  target_id        = "i-024af2adfe13f3775"
}
