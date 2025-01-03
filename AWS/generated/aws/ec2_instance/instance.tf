resource "aws_instance" "tfer--i-024af2adfe13f3775_signalling" {
  ami                         = "ami-0ddf631ad198e005e"
  associate_public_ip_address = "true"
  availability_zone           = "ap-northeast-1c"

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_core_count = "1"

  cpu_options {
    core_count       = "1"
    threads_per_core = "1"
  }

  cpu_threads_per_core = "1"

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_stop        = "false"
  disable_api_termination = "false"
  ebs_optimized           = "false"

  enclave_options {
    enabled = "false"
  }

  get_password_data                    = "false"
  hibernation                          = "false"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.nano"
  ipv6_address_count                   = "0"
  key_name                             = "signalling"

  maintenance_options {
    auto_recovery = "default"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "optional"
    instance_metadata_tags      = "disabled"
  }

  monitoring                 = "false"
  placement_partition_number = "0"

  private_dns_name_options {
    enable_resource_name_dns_a_record    = "true"
    enable_resource_name_dns_aaaa_record = "false"
    hostname_type                        = "ip-name"
  }

  private_ip = "172.31.5.56"

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    iops                  = "3000"
    throughput            = "125"
    volume_size           = "8"
    volume_type           = "gp3"
  }

  security_groups   = ["launch-wizard-1"]
  source_dest_check = "true"
  subnet_id         = "subnet-1057e94b"

  tags = {
    Name = "signalling"
  }

  tags_all = {
    Name = "signalling"
  }

  tenancy                = "default"
  vpc_security_group_ids = ["sg-03036289bc0b0b838"]
}
