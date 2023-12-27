#!/bin/sh

if [ "$(id -u)" -eq "0" ]; then
        cat /etc/rancher/k3s/k3s.yaml
else
        sudo cat /etc/rancher/k3s/k3s.yaml
fi
