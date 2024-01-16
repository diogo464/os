#!/bin/sh
mkdir -p /var/lib/rancher/k3s
exec k3s agent \
        --server $(cat /var/server) \
        --token-file /var/token &
