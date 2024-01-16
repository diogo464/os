#!/bin/bash

PREFIX="git.d464.sh/infra/os"
TAG="latest"
PUSH=${PUSH:-"0"}

docker build -t "$PREFIX/base:$TAG" -f base/Containerfile base/
docker build -t "$PREFIX/kube:$TAG" -f kube/Containerfile kube/
docker build -t "$PREFIX/nas:$TAG" -f nas/Containerfile nas/
docker build -t "$PREFIX/builder:$TAG" -f builder/Containerfile builder/
docker build -t "$PREFIX/router:$TAG" -f router/Containerfile router/

if [ "$PUSH" -eq "1" ]; then
	docker push "$PREFIX/base:$TAG"
	docker push "$PREFIX/kube:$TAG"
	docker push "$PREFIX/nas:$TAG"
	docker push "$PREFIX/builder:$TAG"
	docker push "$PREFIX/router:$TAG"
fi
