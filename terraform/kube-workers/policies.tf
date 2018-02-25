resource "aws_iam_instance_profile" "kube_workers" {
  name  = "kube_workers-profile"
  role = "${aws_iam_role.kube_workers_ec2.name}"
}

data "aws_iam_policy_document" "kube_workers_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kube_workers_ec2" {
  name               = "kube_workers-ec2"
  assume_role_policy = "${data.aws_iam_policy_document.kube_workers_assume_role.json}"
}

data "aws_iam_policy_document" "kube_workers-ec2" {
  statement {
    actions = ["ssm:GetParameter"]

    resources = ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.ssm_param_key}"]
  }

  statement {
    actions = [
      "kms:Decrypt",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "kube_workers-ec2" {
  name   = "kube_workers-for-ec2-policy"
  role   = "${aws_iam_role.kube_workers_ec2.id}"
  policy = "${data.aws_iam_policy_document.kube_workers-ec2.json}"
}
