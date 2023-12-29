#!/bin/sh

if [ "$(id -u)" -eq "0" ]; then
        cat /var/lib/rancher/k3s/server/token
else
        sudo cat /var/lib/rancher/k3s/server/token
fi
