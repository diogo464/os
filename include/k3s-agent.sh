#!/bin/sh
mkdir -p /var/k3s
k3s agent \
        --selinux \
        --data-dir /var/k3s \
        --default-local-storage-path /var/volumes \
        --server $(cat /var/server) \
        --token-file /var/token || exit 1
systemd-notify --ready
