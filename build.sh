#!/bin/bash

PREFIX="git.d464.sh/infra/os"
TAG="latest"
PUSH=${PUSH:-"0"}

docker build -t "$PREFIX/base:$TAG" -f base.containerfile .
docker build -t "$PREFIX/kube:$TAG" -f kube.containerfile .
docker build -t "$PREFIX/nas:$TAG" -f nas.containerfile .
docker build -t "$PREFIX/builder:$TAG" -f builder.containerfile .

if [ "$PUSH" -eq "1" ]; then
	docker push "$PREFIX/base:$TAG"
	docker push "$PREFIX/kube:$TAG"
	docker push "$PREFIX/nas:$TAG"
	docker push "$PREFIX/builder:$TAG"
fi
