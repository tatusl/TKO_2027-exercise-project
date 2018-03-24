variable "env" {
  description = "The environment"
}

variable "instance_type" {
  description = "Type of instance to provision"
  default     = "t2.micro"
}

variable "allowed_hosts" {
  type        = "list"
  description = "CIDR block of allowed hosts"
  default     = ["193.65.194.73/32"]
}
