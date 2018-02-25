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

resource "aws_instance" "kube_master" {
  ami                    = "${var.ami_id}"
  instance_type          = "t2.small"
  key_name               = "${data.terraform_remote_state.kube-common.kube_cluster_node_ssh_key}"
  iam_instance_profile   = "${aws_iam_instance_profile.k8s_master.id}"
  vpc_security_group_ids = ["${data.terraform_remote_state.kube-common.kube_cluster_security_group}"]
  user_data              = "${file("files/user_data.sh")}"

  tags {
    Name = "kube_master"
  }
}

data "aws_iam_policy_document" "k8s_master_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "k8s_master" {
  name               = "k8s-master"
  assume_role_policy = "${data.aws_iam_policy_document.k8s_master_assume_role.json}"
}

resource "aws_iam_instance_profile" "k8s_master" {
  name = "kube-master"
  role = "${aws_iam_role.k8s_master.name}"
}

resource "aws_iam_role_policy" "k8s_master" {
  name   = "k8s-master"
  role   = "${aws_iam_role.k8s_master.id}"
  policy = "${data.aws_iam_policy_document.k8s_master.json}"
}

data "aws_iam_policy_document" "k8s_master" {
  statement {
    actions = [
      "ssm:GetParameterHistory",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "ssm:PutParameter",
    ]

    resources = ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.ssm_prefix}/*"]
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
    ]

    resources = ["*"]
  }
}
