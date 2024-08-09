#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <hostname>"
	exit 1
fi

ssh "$1" systemd-sysext status
ssh "$1" systemd-sysext list
