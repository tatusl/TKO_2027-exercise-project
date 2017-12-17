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
  vpc_security_group_ids = ["${aws_security_group.kube_cluster_node.id}"]

  tags {
    Name = "kube_master"
  }
}

resource "aws_instance" "kube_worker" {
  ami                    = "ami-8fd760f6"                                 # Ubuntu 16.04 LTS in eu-west 1
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.kube_cluster_node.key_name}"
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
    cidr_blocks = ["86.115.198.116/32"]
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
