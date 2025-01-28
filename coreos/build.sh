#!/usr/bin/env bash

docker build \
	-t git.d464.sh/infra/os/coreos:latest \
	-f "$(dirname $0)/Containerfile" \
	--build-arg BUILDER_VERSION=$(curl -s "https://builds.coreos.fedoraproject.org/streams/stable.json" | jq -r '.architectures.x86_64.artifacts.metal.release' | cut -d '.' -f 1) \
	"$(dirname $0)/"

if [ "$PUSH" = "1" ]; then
	docker push git.d464.sh/infra/os/coreos:latest
fi
