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

resource "aws_key_pair" "bastion" {
  key_name   = "expro-bastion"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allows ssh from listed IPs"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags {
    Name = "bastion"
  }
}

resource "aws_security_group_rule" "allow_ssh_in" {
  security_group_id = "${aws_security_group.bastion.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = "${var.allowed_hosts}"
}

resource "aws_security_group_rule" "allow_all_out" {
  security_group_id = "${aws_security_group.bastion.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

// Add our instance description
resource "aws_instance" "bastion" {
  ami               = "ami-d834aba1"
  source_dest_check = false
  instance_type     = "${var.instance_type}"
  subnet_id         = "${data.terraform_remote_state.vpc.public_subnets[0]}"
  key_name          = "${aws_key_pair.bastion.key_name}"
  security_groups   = ["${aws_security_group.bastion.id}"]

  tags {
    Name = "bastion"
  }
}

// Setup our elastic ip
resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
}
