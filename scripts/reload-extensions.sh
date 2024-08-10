#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <hostname>"
	exit 1
fi

ssh "$1" sudo systemd-sysext refresh #--force
