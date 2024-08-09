#!/usr/bin/sh

EXTENSIONS=$(dirname $0)/../extensions/
SCRIPTS="$(dirname $0)/../scripts/"
HOSTNAME="xen"

$SCRIPTS/fetch-binaries.sh || exit 1
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/router
$SCRIPTS/reload-extensions.sh $HOSTNAME

ssh "$HOSTNAME" sudo systemctl daemon-reload
ssh "$HOSTNAME" sudo systemctl enable router blocky wgs wgs-hosts.timer
ssh "$HOSTNAME" sudo systemctl restart router blocky wgs
ssh "$HOSTNAME" sudo systemctl restart systemd-networkd
