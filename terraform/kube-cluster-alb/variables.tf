variable "env" {
  description = "The environment, provided by `tf`"
}

variable "name" {
  description = "Name of the module"
  default     = "k8s-cluster"
}

variable "ssl_arn" {
  description = "SSL certificate arn"
  default     = "arn:aws:acm:eu-west-1:082303500113:certificate/dedca698-8c44-4c7a-9e1a-74c1c975daac"
}
