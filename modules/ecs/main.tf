resource "aws_iam_role" "ecs-service-role" {
  name               = "${var.environment_name}-ecs-service-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-service-policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
  role       = "${aws_iam_role.ecs-service-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs-service-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-instance-role" {
  name               = "${var.environment_name}-ecs-instance-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-instance-policy.json}"
}

data "aws_iam_policy_document" "ecs-instance-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = "${aws_iam_role.ecs-instance-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "${var.environment_name}-ecs-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs-instance-role.id}"
}

resource "aws_alb" "ecs-load-balancer" {
  name            = "${var.environment_name}-ecs-load-balancer"
  security_groups = ["${var.security_group}"]
  subnets         = ["${var.public_subnets}"]

  tags {
    Name = "${var.environment_name} ecs-load-balancer"
  }
}

resource "aws_alb_target_group" "ecs-target-group" {
  name     = "${var.environment_name}-ecs-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags {
    Name = "${var.environment_name} ecs-target-group"
  }
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = "${aws_alb.ecs-load-balancer.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
    type             = "forward"
  }
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
  name                 = "${var.environment_name}-ecs-launch-configuration"
  image_id             = "${var.ami_id}"
  instance_type        = "${var.ec2_instance}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"

  # root_block_device {
  #   volume_type           = "standard"
  #   volume_size           = 10
  #   delete_on_termination = true
  # }

  lifecycle {
    create_before_destroy = true
  }
  security_groups             = ["${var.security_group}"]
  associate_public_ip_address = "true"
  key_name                    = "${var.ecs_key_pair_name}"
  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.ecs_cluster} >> /etc/ecs/ecs.config
EOF
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                 = "${var.environment_name}-ecs-autoscaling-group"
  max_size             = "${var.max_instance_size}"
  min_size             = "${var.min_instance_size}"
  desired_capacity     = "${var.desired_capacity}"
  vpc_zone_identifier  = ["${var.public_subnets}"]
  launch_configuration = "${aws_launch_configuration.ecs-launch-configuration.name}"
  health_check_type    = "ELB"
}

resource "aws_ecs_cluster" "test-ecs-cluster" {
  name = "${var.ecs_cluster}"
}

resource "aws_ecs_task_definition" "app" {
  family = "${var.ecs_cluster}-task"

  container_definitions = <<DEFINITION
[
  {
    "environment": [
      {
        "name": "DB_HOST",
        "value": "${var.db_host}"
      },
      {
        "name": "DB_DATABASE",
        "value": "${var.db_name}"
      },
      {
        "name": "DB_USERNAME",
        "value": "${var.db_username}"
      },
      {
        "name": "DB_PASSWORD",
        "value": "${var.db_password}"
      },
      {
        "name": "AWS_DEFAULT_REGION",
        "value": "${var.aws_region}"
      },
      {
        "name": "AWS_BUCKET",
        "value": "${var.bucket_name}"
      },
      {
        "name": "AWS_URL",
        "value": "https://${var.cloudfront_domain_name}"
      },
      {
        "name": "AWS_ACCESS_KEY_ID",
        "value": "${var.aws_access_key}"
      },
      {
        "name": "AWS_SECRET_ACCESS_KEY",
        "value": "${var.aws_secret_key}"
      }
    ],
    "name": "app",
    "image": "${var.docker_image}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 80
      }
    ],
    "memory": 256,
    "cpu": 2
  }
]
DEFINITION
}

data "aws_ecs_task_definition" "app" {
  task_definition = "${aws_ecs_task_definition.app.family}"
  depends_on      = ["aws_ecs_task_definition.app"]
}

resource "aws_ecs_service" "ecs-service" {
  name                = "${var.ecs_cluster}-ecs-service"
  iam_role            = "${aws_iam_role.ecs-service-role.name}"
  cluster             = "${aws_ecs_cluster.test-ecs-cluster.id}"
  task_definition     = "${aws_ecs_task_definition.app.family}:${max("${aws_ecs_task_definition.app.revision}", "${data.aws_ecs_task_definition.app.revision}")}"
  scheduling_strategy = "DAEMON"
  depends_on          = ["aws_alb.ecs-load-balancer"]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
    container_port   = 8080
    container_name   = "app"
  }
}
