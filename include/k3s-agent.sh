#!/bin/sh
mkdir -p /var/k3s
k3s agent \
        --selinux \
        --data-dir /var/k3s \
        --server $(cat /var/server) \
        --token-file /var/token &
systemd-notify --ready
