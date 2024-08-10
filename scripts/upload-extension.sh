#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <hostname> <extension path>"
	exit 1
fi

rsync -avzpL --delete --mkpath --rsync-path "sudo rsync" "$2/" "$1:/var/lib/extensions/$(basename $2)/"
