resource "aws_security_group" "rds-in" {
  name   = "${var.environment_name} - RDS"
  vpc_id = "${var.vpc_id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 3306
    to_port     = 3306
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

module "rds" {
  source                  = "terraform-aws-modules/rds/aws"
  version                 = "1.28.0"
  identifier              = "ha-${var.environment_name}-db"
  engine                  = "mysql"
  engine_version          = "5.7.22"
  instance_class          = "${var.db_instance}"
  allocated_storage       = 5
  name                    = "${var.db_name}"
  username                = "${var.db_username}"
  password                = "${var.db_password}"
  port                    = "3306"
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:30-06:00"
  backup_retention_period = "7"

  db_subnet_group_name = "${var.db_subnet_group}"
  family               = "mysql5.7"
  major_engine_version = "5.7"

  final_snapshot_identifier = "ha-${var.environment_name}-db"
  deletion_protection       = false
  backup_retention_period   = 0
  vpc_security_group_ids    = ["${aws_security_group.rds-in.id}"]

  tags = {
    Terraform   = "true"
    Environment = "${var.environment_name}"
  }
}
