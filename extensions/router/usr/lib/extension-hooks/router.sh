#!/usr/bin/env -S bash -x

systemctl restart systemd-networkd router wgs wgs-hosts.timer blocky
