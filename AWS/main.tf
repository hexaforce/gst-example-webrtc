provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

terraform {
  required_providers {
    aws = {
      version = "~> 5.82.2"
    }
  }
}

resource "aws_vpc" "gstreamer-vpc" {
  assign_generated_ipv6_cidr_block     = false
  cidr_block                           = "172.31.0.0/16"
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  enable_network_address_usage_metrics = false
  instance_tenancy                     = "default"

  tags = {
    Name = "gstreamer-vpc"
  }

  tags_all = {
    Name = "gstreamer-vpc"
  }
}

resource "aws_internet_gateway" "gstreamer-igw" {
  tags = {
    Name = "gstreamer-igw"
  }

  tags_all = {
    Name = "gstreamer-igw"
  }

  vpc_id = aws_vpc.gstreamer-vpc.id
}

resource "aws_route_table" "gstreamer-rtb" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gstreamer-igw.id
  }

  tags = {
    Name = "gstreamer-rtb"
  }

  tags_all = {
    Name = "gstreamer-rtb"
  }

  vpc_id = aws_vpc.gstreamer-vpc.id
}

resource "aws_main_route_table_association" "gstreamer-mrtbl" {
  route_table_id = aws_route_table.gstreamer-rtb.id
  vpc_id         = aws_vpc.gstreamer-vpc.id
}

resource "aws_subnet" "gstreamer-subnet-1c" {
  assign_ipv6_address_on_creation                = false
  cidr_block                                     = "172.31.0.0/20"
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv6_native                                    = false
  map_public_ip_on_launch                        = true
  private_dns_hostname_type_on_launch            = "ip-name"
  availability_zone                              = "ap-northeast-1c"

  tags = {
    Name = "gstreamer-1c"
  }

  tags_all = {
    Name = "gstreamer-1c"
  }

  vpc_id = aws_vpc.gstreamer-vpc.id
}

resource "aws_route_table_association" "gstreamer-subnet-1c" {
  route_table_id = aws_route_table.gstreamer-rtb.id
  subnet_id      = aws_subnet.gstreamer-subnet-1c.id
}

resource "aws_subnet" "gstreamer-subnet-1a" {
  assign_ipv6_address_on_creation                = false
  cidr_block                                     = "172.31.32.0/20"
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv6_native                                    = false
  map_public_ip_on_launch                        = true
  private_dns_hostname_type_on_launch            = "ip-name"
  availability_zone                              = "ap-northeast-1a"

  tags = {
    Name = "gstreamer-1a"
  }

  tags_all = {
    Name = "gstreamer-1a"
  }

  vpc_id = aws_vpc.gstreamer-vpc.id
}

resource "aws_route_table_association" "gstreamer-subnet-1a" {
  route_table_id = aws_route_table.gstreamer-rtb.id
  subnet_id      = aws_subnet.gstreamer-subnet-1a.id
}
