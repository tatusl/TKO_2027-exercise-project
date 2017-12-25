provider "aws" {
  region = "eu-west-1"
}

resource "aws_key_pair" "kube_cluster_node" {
  key_name   = "kube_cluster_node"
  public_key = "${file("files/cluster_node_public_key.pem.pub")}"
}

resource "aws_instance" "kube_master" {
  ami                    = "ami-8fd760f6"                                 # Ubuntu 16.04 LTS in eu-west 1
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.kube_cluster_node.key_name}"
  iam_instance_profile   = "${aws_iam_instance_profile.k8s_master.id}"
  vpc_security_group_ids = ["${aws_security_group.kube_cluster_node.id}"]

  tags {
    Name = "kube_master"
  }
}

resource "aws_instance" "kube_worker" {
  ami                    = "ami-8fd760f6"                                 # Ubuntu 16.04 LTS in eu-west 1
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.kube_cluster_node.key_name}"
  iam_instance_profile   = "${aws_iam_instance_profile.k8s_master.id}"
  vpc_security_group_ids = ["${aws_security_group.kube_cluster_node.id}"]

  tags {
    Name = "kube_worker"
  }
}

resource "aws_security_group" "kube_cluster_node" {
  name        = "kube_cluster_nodes"
  description = "Allow ssh from own ip, allow all out, allow all within this security group"
  vpc_id      = "vpc-ad4434c9"                                                               # Account default VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "86.115.198.116/32",
      "80.222.55.12/32"
    ]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

data "aws_iam_policy_document" "k8s_master" {
  statement {
    actions = [
     "ec2:*",
     "elasticloadbalancing:*",
     "autoscaling:DescribeAutoScalingGroups",
     "autoscaling:UpdateAutoScalingGroup"
  ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "k8s_master" {
  name   = "k8s-master"
  role   = "${aws_iam_role.k8s_master.id}"
  policy = "${data.aws_iam_policy_document.k8s_master.json}"
}
