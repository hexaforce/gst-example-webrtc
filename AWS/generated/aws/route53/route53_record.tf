resource "aws_route53_record" "tfer--Z202OAD1EJUZW3__4d89cc22454daa96d41f1370280fb5e5-002E-hexaforce-002E-io-002E-_CNAME_" {
  multivalue_answer_routing_policy = "false"
  name                             = "_4d89cc22454daa96d41f1370280fb5e5.hexaforce.io"
  records                          = ["_488526ad26715505a204f43424fe2026.acm-validations.aws"]
  ttl                              = "300"
  type                             = "CNAME"
  zone_id                          = "${aws_route53_zone.tfer--Z202OAD1EJUZW3_hexaforce-002E-io.zone_id}"
}

resource "aws_route53_record" "tfer--Z202OAD1EJUZW3_gst-webrtc-api-002E-hexaforce-002E-io-002E-_A_" {
  alias {
    evaluate_target_health = "true"
    name                   = "dualstack.hexaforce-1505457749.ap-northeast-1.elb.amazonaws.com"
    zone_id                = "Z14GRHDCWA56QT"
  }

  multivalue_answer_routing_policy = "false"
  name                             = "gst-webrtc-api.hexaforce.io"
  type                             = "A"
  zone_id                          = "${aws_route53_zone.tfer--Z202OAD1EJUZW3_hexaforce-002E-io.zone_id}"
}

resource "aws_route53_record" "tfer--Z202OAD1EJUZW3_gst-webrtc-signalling-server-002E-hexaforce-002E-io-002E-_A_" {
  alias {
    evaluate_target_health = "true"
    name                   = "dualstack.hexaforce-1505457749.ap-northeast-1.elb.amazonaws.com"
    zone_id                = "Z14GRHDCWA56QT"
  }

  multivalue_answer_routing_policy = "false"
  name                             = "gst-webrtc-signalling-server.hexaforce.io"
  type                             = "A"
  zone_id                          = "${aws_route53_zone.tfer--Z202OAD1EJUZW3_hexaforce-002E-io.zone_id}"
}

resource "aws_route53_record" "tfer--Z202OAD1EJUZW3_hexaforce-002E-io-002E-_NS_" {
  multivalue_answer_routing_policy = "false"
  name                             = "hexaforce.io"
  records                          = ["ns-126.awsdns-15.com.", "ns-1517.awsdns-61.org.", "ns-1785.awsdns-31.co.uk.", "ns-729.awsdns-27.net."]
  ttl                              = "172800"
  type                             = "NS"
  zone_id                          = "${aws_route53_zone.tfer--Z202OAD1EJUZW3_hexaforce-002E-io.zone_id}"
}

resource "aws_route53_record" "tfer--Z202OAD1EJUZW3_hexaforce-002E-io-002E-_SOA_" {
  multivalue_answer_routing_policy = "false"
  name                             = "hexaforce.io"
  records                          = ["ns-1517.awsdns-61.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
  ttl                              = "900"
  type                             = "SOA"
  zone_id                          = "${aws_route53_zone.tfer--Z202OAD1EJUZW3_hexaforce-002E-io.zone_id}"
}

resource "aws_route53_record" "tfer--Z202OAD1EJUZW3_signalling-002E-hexaforce-002E-io-002E-_A_" {
  alias {
    evaluate_target_health = "true"
    name                   = "dualstack.hexaforce-1505457749.ap-northeast-1.elb.amazonaws.com"
    zone_id                = "Z14GRHDCWA56QT"
  }

  multivalue_answer_routing_policy = "false"
  name                             = "signalling.hexaforce.io"
  type                             = "A"
  zone_id                          = "${aws_route53_zone.tfer--Z202OAD1EJUZW3_hexaforce-002E-io.zone_id}"
}

resource "aws_route53_record" "tfer--Z202OAD1EJUZW3_webrtc-002E-hexaforce-002E-io-002E-_A_" {
  alias {
    evaluate_target_health = "true"
    name                   = "dualstack.hexaforce-1505457749.ap-northeast-1.elb.amazonaws.com"
    zone_id                = "Z14GRHDCWA56QT"
  }

  multivalue_answer_routing_policy = "false"
  name                             = "webrtc.hexaforce.io"
  type                             = "A"
  zone_id                          = "${aws_route53_zone.tfer--Z202OAD1EJUZW3_hexaforce-002E-io.zone_id}"
}
