resource "aws_security_group" "tfer--default_sg-37f79d4e" {
  description = "default VPC security group"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    from_port = "0"
    protocol  = "-1"
    self      = "true"
    to_port   = "0"
  }

  name = "default"

  tags = {
    Name = "default"
  }

  tags_all = {
    Name = "default"
  }

  vpc_id = "vpc-ef329e88"
}

resource "aws_security_group" "tfer--hexaforce_sg-06ee73d054391c20b" {
  description = "hexaforce ALB"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "443"
    protocol    = "tcp"
    self        = "false"
    to_port     = "443"
  }

  name   = "hexaforce"
  vpc_id = "vpc-ef329e88"
}

resource "aws_security_group" "tfer--launch-wizard-1_sg-03036289bc0b0b838" {
  description = "launch-wizard-1 created 2024-12-30T01:06:33.727Z"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "22"
    protocol    = "tcp"
    self        = "false"
    to_port     = "22"
  }

  ingress {
    from_port       = "0"
    protocol        = "-1"
    security_groups = ["${data.terraform_remote_state.sg.outputs.aws_security_group_tfer--hexaforce_sg-06ee73d054391c20b_id}"]
    self            = "false"
    to_port         = "0"
  }

  name   = "launch-wizard-1"
  vpc_id = "vpc-ef329e88"
}
