resource "aws_security_group" "gstreamer-sg-alb" {
  description = "gstreamer loadbalancer"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = -1
    self        = false
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    self        = false
    to_port     = 443
  }

  name   = "gstreamer-sg-alb"
  vpc_id = aws_vpc.gstreamer-vpc.id
}

resource "aws_security_group" "gstreamer-sg-instance" {
  description = "gstreamer instance"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = -1
    self        = false
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    self        = false
    to_port     = 22
  }

  ingress {
    from_port       = 0
    protocol        = -1
    security_groups = [aws_security_group.gstreamer-sg-alb.id]
    self            = false
    to_port         = 0
  }

  name   = "gstreamer-sg-instance"
  vpc_id = aws_vpc.gstreamer-vpc.id
}

resource "aws_key_pair" "gstreamer-demo-instance" {
  key_name   = "gstreamer-demo-instance"
  public_key = file("~/.ssh/gstreamer-demo-instance.pub")
}

resource "aws_instance" "gstreamer-demo-instance" {
  ami                         = "ami-0ddf631ad198e005e"
  associate_public_ip_address = true
  availability_zone           = "ap-northeast-1c"

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_stop        = false
  disable_api_termination = false
  ebs_optimized           = false

  enclave_options {
    enabled = false
  }

  get_password_data                    = false
  hibernation                          = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.nano"
  ipv6_address_count                   = 0
  key_name                             = aws_key_pair.gstreamer-demo-instance.key_name

  maintenance_options {
    auto_recovery = "default"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
    instance_metadata_tags      = "disabled"
  }

  monitoring                 = false
  placement_partition_number = 0

  private_dns_name_options {
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }

  private_ip = "172.31.10.10"

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 3000
    throughput            = 125
    volume_size           = 8
    volume_type           = "gp3"
  }

  # security_groups   = [aws_security_group.gstreamer-sg-instance.id]
  source_dest_check = true
  subnet_id         = aws_subnet.gstreamer-subnet-1c.id

  tags = {
    Name = "gstreamer-demo-instance"
  }

  tags_all = {
    Name = "gstreamer-demo-instance"
  }

  tenancy                = "default"
  vpc_security_group_ids = [aws_security_group.gstreamer-sg-instance.id]
}

output "gstreamer_demo_instance_public_dns" {
  value = aws_instance.gstreamer-demo-instance.public_dns
  description = "The public DNS name of the GStreamer demo instance"
}
