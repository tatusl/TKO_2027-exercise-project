provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "ep_state_bucket" {
  bucket        = "tatusl-ep-terraform-remote-state"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}
