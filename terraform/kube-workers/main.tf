provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "terraform_remote_state" "kube-common" {
  backend = "s3"

  config {
    bucket = "tatusl-ep-terraform-remote-state"
    key    = "kube-common_prod.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "tatusl-ep-terraform-remote-state"
    key    = "vpc_${var.env}.tfstate"
    region = "eu-west-1"
  }
}

resource "aws_launch_configuration" "kube_workers" {
  name_prefix          = "kube_workers_launch_config"
  instance_type        = "${var.instance_type}"
  image_id             = "${var.ami_id}"
  iam_instance_profile = "${aws_iam_instance_profile.kube_workers.id}"
  security_groups      = ["${data.terraform_remote_state.kube-common.kube_cluster_security_group}"]
  user_data            = "${file("files/user_data.sh")}"
  key_name             = "${data.terraform_remote_state.kube-common.kube_cluster_node_ssh_key}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs" {
  name                 = "kube_workers_asg"
  vpc_zone_identifier  = ["${data.terraform_remote_state.vpc.private_subnets[0]}"]
  launch_configuration = "${aws_launch_configuration.kube_workers.name}"
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  desired_capacity     = "${var.desired_capacity}"

  tag {
    key                 = "Name"
    value               = "kube-worker"
    propagate_at_launch = true
  }
}
