#!/usr/bin/env -S bash -x

sysctl --system
systemctl restart systemd-networkd
systemctl start router wgs wgs-hosts.timer blocky
