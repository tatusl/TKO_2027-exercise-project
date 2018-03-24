output "bastion_public_ip" {
  value = "${aws_eip.bastion.public_ip}"
}

output "bastion_private_ip" {
  value = "${aws_eip.bastion.private_ip}"
}

output "bastion_security_group_id" {
  value = "${aws_security_group.bastion.id}"
}

