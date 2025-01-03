resource "aws_lb" "tfer--hexaforce" {
  client_keep_alive = "3600"

  connection_logs {
    enabled = "false"
  }

  desync_mitigation_mode                      = "defensive"
  drop_invalid_header_fields                  = "false"
  enable_cross_zone_load_balancing            = "true"
  enable_deletion_protection                  = "false"
  enable_http2                                = "true"
  enable_tls_version_and_cipher_suite_headers = "false"
  enable_waf_fail_open                        = "false"
  enable_xff_client_port                      = "false"
  enable_zonal_shift                          = "false"
  idle_timeout                                = "60"
  internal                                    = "false"
  ip_address_type                             = "ipv4"
  load_balancer_type                          = "application"
  name                                        = "hexaforce"
  preserve_host_header                        = "false"
  security_groups                             = ["sg-06ee73d054391c20b", "sg-37f79d4e"]

  subnet_mapping {
    subnet_id = "subnet-1057e94b"
  }

  subnet_mapping {
    subnet_id = "subnet-10c48659"
  }

  subnets                    = ["subnet-1057e94b", "subnet-10c48659"]
  xff_header_processing_mode = "append"
}
