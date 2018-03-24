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

data "terraform_remote_state" "bastion" {
  backend = "s3"

  config {
    bucket = "tatusl-ep-terraform-remote-state"
    key    = "bastion_${var.env}.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "kube-cluster-alb" {
  backend = "s3"

  config {
    bucket = "tatusl-ep-terraform-remote-state"
    key    = "kube-cluster-alb_${var.env}.tfstate"
    region = "eu-west-1"
  }
}

resource "aws_key_pair" "kube_cluster_node" {
  key_name   = "kube_cluster_node"
  public_key = "${file("files/cluster_node_public_key.pem.pub")}"
}

# Refactor to security_group_rules
resource "aws_security_group" "kube_cluster_node" {
  name        = "kube_cluster_nodes"
  description = "Allow all out, allow all in within this security group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${data.terraform_remote_state.bastion.bastion_security_group_id}"]
  }

  # TODO: Kubernetes API access (port 6443)should be only allowed for master
  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = ["${data.terraform_remote_state.bastion.bastion_security_group_id}"]
  }

  # TODO: ingress-nginx NodePort (30080) should be only allowed for workers
  ingress {
    from_port       = 30080
    to_port         = 30080
    protocol        = "tcp"
    security_groups = ["${data.terraform_remote_state.kube-cluster-alb.security_group_id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
