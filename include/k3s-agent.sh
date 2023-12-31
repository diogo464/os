#!/bin/sh
mkdir -p /var/lib/rancher/k3s
exec k3s agent \
        --selinux \
        --server $(cat /var/server) \
        --token-file /var/token &
