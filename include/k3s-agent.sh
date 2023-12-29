#!/bin/sh
mkdir -p /var/lib/rancher/k3s
k3s agent \
        --selinux \
        --server $(cat /var/server) \
        --token-file /var/token &
systemd-notify --ready
