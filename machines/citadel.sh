#!/usr/bin/sh

EXTENSIONS=$(dirname $0)/../extensions/
SCRIPTS="$(dirname $0)/../scripts/"
HOSTNAME="citadel"

$SCRIPTS/fetch-binaries.sh || exit 1
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/ether-dhcp
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/nas-gitea
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/nas-k3s
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/nas-samba
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/nas-zsnap
$SCRIPTS/reload-extensions.sh $HOSTNAME

ssh "$HOSTNAME" sudo systemctl daemon-reload
ssh "$HOSTNAME" sudo systemctl enable \
	zfs-scrub-monthly@borealis.timer \
	zfs-scrub-monthly@blackmesa.timer
ssh "$HOSTNAME" sudo systemctl enable --now k3s zsnap
ssh "$HOSTNAME" sudo systemctl start gitea
ssh "$HOSTNAME" sudo systemctl restart systemd-networkd
