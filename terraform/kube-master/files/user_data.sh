#!/bin/bash

set -eux

kubeadm init --pod-network-cidr=10.244.0.0/16

echo "export KUBECONFIG=/etc/kubernetes/admin.conf" > ~/.profile

. ~/.profile

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml

JOIN_COMMAND=$(kubeadm token create --print-join-command)

aws ssm put-parameter --name "/exercise_project/kube_cluster_join_command" --value "$JOIN_COMMAND" --type "SecureString" --overwrite --region eu-west-1
