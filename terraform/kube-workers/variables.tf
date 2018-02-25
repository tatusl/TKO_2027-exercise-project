variable "ami_id" {
  description = "ID of AMI for cluster worker nodes"
  default     = "ami-02bbc07b"
}

variable "instance_type" {
  description = "Type of EC2 instances"
  default     = "t2.small"
}

variable "min_size" {
  description = "Minimum size of cluster autoscaling group"
  default     = 0
}

variable "max_size" {
  description = "Maximum size of cluster autoscaling group"
  default     = 4
}

variable "desired_capacity" {
  description = "Desired capacity of cluster autoscaling group"
  default     = 2
}

variable "ssm_param_key" {
  description = "Name of Kube join command parameter in SSM"
  default     = "exercise_project/kube_cluster_join_command"
}
