variable "env" {
  description = "The environment, provided by `tf`"
}

variable "ami_id" {
  description = "Master node AMI id. Uses Kubernetes common AMI"
  default     = "ami-02bbc07b"
}

variable "ssm_prefix" {
  description = "Parameter prefix for SSM Parameter Store"
  default     = "exercise_project"
}
