provider "aws" {
  region = "eu-west-1"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "tatusl-ep-terraform-remote-state"
    key    = "vpc_${var.env}.tfstate"
    region = "eu-west-1"
  }
}

resource "aws_security_group" "k8s-cluster" {
  name        = "${var.name}-alb"
  description = "allow HTTPS to ${var.name} (ALB)"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_alb" "k8s-cluster" {
  name         = "${var.name}"
  internal     = false
  idle_timeout = "300"

  security_groups = [
    "${aws_security_group.k8s-cluster.id}",
  ]

  subnets = ["${data.terraform_remote_state.vpc.public_subnets}"]

  tags {
    Name = "${var.name}"
  }
}

resource "aws_alb_listener" "k8s-cluster" {
  load_balancer_arn = "${aws_alb.k8s-cluster.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.ssl_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.k8s-cluster.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "k8s-cluster" {
  name     = "${var.name}-nginx-ingress"
  port     = 30080
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"

  health_check {
    interval = 8
    path     = "/healthz"
    timeout  = 6
  }
}
