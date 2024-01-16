#!/bin/bash

PREFIX="git.d464.sh/infra/os"
TAG="latest"
PUSH=${PUSH:-"0"}

docker build -t "$PREFIX/base:$TAG" -f base/Containerfile base/ || exit 1
docker build -t "$PREFIX/kube:$TAG" -f kube/Containerfile kube/ || exit 1
docker build -t "$PREFIX/nas:$TAG" -f nas/Containerfile nas/ || exit 1
docker build -t "$PREFIX/builder:$TAG" -f builder/Containerfile builder/ || exit 1
docker build -t "$PREFIX/router:$TAG" -f router/Containerfile router/ || exit 1

if [ "$PUSH" -eq "1" ]; then
	docker push "$PREFIX/base:$TAG" || exit 1
	docker push "$PREFIX/kube:$TAG" || exit 1
	docker push "$PREFIX/nas:$TAG" || exit 1
	docker push "$PREFIX/builder:$TAG" || exit 1
	docker push "$PREFIX/router:$TAG" || exit 1
fi
