#!/usr/bin/env -S bash -x
systemctl enable --now docker-system-prune.timer
systemctl restart act_runner
