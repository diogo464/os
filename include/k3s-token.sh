#!/bin/sh

if [ "$(id -u)" -eq "0" ]; then
        cat /var/k3s/server/token
else
        sudo cat /var/k3s/server/token
fi
