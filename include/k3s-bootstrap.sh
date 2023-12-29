#!/bin/sh
mkdir -p /var/lib/rancher/k3s
k3s server \
        --cluster-init \
        --selinux \
        --cluster-cidr 10.1.0.0/16 \
        --service-cidr 10.2.0.0/16 \
        --cluster-dns 10.2.0.10 \
        --cluster-domain cluster.local \
        --disable-cloud-controller \
        --disable-helm-controller \
        --disable traefik,servicelb,local-storage || exit 1
systemd-notify --ready
