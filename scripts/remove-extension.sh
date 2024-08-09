#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <hostname> <extension name>"	
	exit 1
fi

if [ "$(basename $2)" != "$2" ]; then
	echo "Invalid extension name"
	exit 1
fi

ssh "$1" "sudo rm -rf /var/lib/extensions/$2"
"$(dirname $0)/reload-extensions.sh" $1
