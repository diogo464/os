#!/bin/sh
mkdir -p /var/k3s
k3s server \
        --selinux \
        --data-dir /var/k3s \
        --cluster-cidr 10.1.0.0/16 \
        --service-cidr 10.2.0.0/16 \
        --cluster-dns 10.2.0.10 \
        --cluster-domain cluster.local \
        --disable-cloud-controller \
        --disable-helm-controller \
        --disable traefik,servicelb \
        --default-local-storage-path /var/volumes \
        --server $(cat /var/server) \
        --token-file /var/token || exit 1
systemd-notify --ready
