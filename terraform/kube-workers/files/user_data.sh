#!/bin/bash

set -eux

$(aws ssm get-parameter --name /exercise_project/kube_cluster_join_command --with-decryption --region eu-west-1 | python -c 'import sys, json; print json.load(sys.stdin)["Parameter"]["Value"]')
