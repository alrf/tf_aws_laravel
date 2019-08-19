variable "environment_name" {}

variable "azs" {
  type = "list"
}

variable "database_subnets" {
  type = "list"
}

variable "public_subnets" {
  type = "list"
}

resource "aws_security_group" "default" {
  name   = "${var.environment_name} - default"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform   = "true"
    Environment = "${var.environment_name}"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.64.0"
  name    = "${var.environment_name}-ha-vpc"
  cidr    = "10.0.0.0/16"

  azs              = "${var.azs}"
  database_subnets = "${var.database_subnets}"
  public_subnets   = "${var.public_subnets}"

  enable_nat_gateway = false
  enable_vpn_gateway = false
  enable_s3_endpoint = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "${var.environment_name}"
  }
}
