#!/bin/sh

if [ "$#" -eq "0" ]; then
        echo "Setup bootstrap server"
        echo "  $0 bootstrap"
        echo "Setup server"
        echo "  $0 server <bootstrap-addr> <token>"
        echo "  bootstrap address should look like https://hostname:6443"
        echo "Setup agent"
        echo "  $0 agent <boostrap-addr> <token>"
        echo "  bootstrap address should look like https://hostname:6443"
        echo
        echo "to redo the setup just run"
        echo "  rm -rf /var/lib/rancher/k3s"
        exit 1
fi

if [ "$(id -u)" -ne "0" ]; then
        echo "must run as root"
        exit 1
fi

MODE=$1
BOOTSTRAP_ADDR=$2
TOKEN=$3

systemctl disable --now k3s.service
if [ -e "/usr/local/bin/k3s.sh" ]; then
        rm /usr/local/bin/k3s.sh
fi

if [ "$MODE" = "bootstrap" ]; then
        ln -s /usr/bin/k3s-bootstrap.sh /usr/local/bin/k3s.sh
elif [ "$MODE" = "server" ]; then
        echo "$BOOTSTRAP_ADDR" > /var/server
        echo "$TOKEN" > /var/token
        ln -s /usr/bin/k3s-server.sh /usr/local/bin/k3s.sh
elif [ "$MODE" = "agent" ]; then
        echo "$BOOTSTRAP_ADDR" > /var/server
        echo "$TOKEN" > /var/token
        ln -s /usr/bin/k3s-agent.sh /usr/local/bin/k3s.sh
else
        echo "invalid usage"       
        exit 1
fi

systemctl enable --now k3s.service
