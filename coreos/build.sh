#!/usr/bin/env bash

docker build -t git.d464.sh/infra/os/coreos:latest -f "$(dirname $0)/Containerfile" "$(dirname $0)/"

if [ "$BUILD" = "1" ]; then
	docker push git.d464.sh/infra/os/coreos:latest
fi
