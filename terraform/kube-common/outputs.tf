output "kube_cluster_node_ssh_key" {
  value = "${aws_key_pair.kube_cluster_node.key_name}"
}

output "kube_cluster_security_group" {
  value = "${aws_security_group.kube_cluster_node.id}"
}
