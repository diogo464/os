#!/usr/bin/env -S bash -x
cp /usr/etc/systemd/resolved.conf /etc/systemd/resolved.conf
systemctl restart systemd-resolved
