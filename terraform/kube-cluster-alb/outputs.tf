output "target_group_arn" {
  description = "ARN of ALB target group"
  value       = "${aws_alb_target_group.k8s-cluster.arn}"
}

output "security_group_id" {
  description = "ARN of ALB target group"
  value       = "${aws_security_group.k8s-cluster.id}"
}
