#!/usr/bin/sh

EXTENSIONS=$(dirname $0)/../extensions/
SCRIPTS="$(dirname $0)/../scripts/"
HOSTNAME="vortigaunt"

$SCRIPTS/fetch-binaries.sh || exit 1
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/ether-dhcp
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/vortigaunt
$SCRIPTS/reload-extensions.sh $HOSTNAME

ssh "$HOSTNAME" sudo systemctl daemon-reload
ssh "$HOSTNAME" systemctl enable act_runner.service
ssh "$HOSTNAME" systemctl restart act_runner.serivce
ssh "$HOSTNAME" sudo systemctl enable docker-system-prune.timer
ssh "$HOSTNAME" sudo systemctl enable --now docker
ssh "$HOSTNAME" sudo systemctl restart systemd-networkd
