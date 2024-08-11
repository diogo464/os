#!/usr/bin/env -S bash -x

EXTENSIONS=$(dirname $0)/../extensions/
SCRIPTS="$(dirname $0)/../scripts/"
HOSTNAME="citadel"

$SCRIPTS/fetch-binaries.sh || exit 1
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/resolved-fix
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/nas
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/nas-gitea
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/nas-k3s
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/nas-samba
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/nas-zsnap
# node-exporter is already running in k3s
$SCRIPTS/upload-extension.sh $HOSTNAME $EXTENSIONS/node-exporter-dashboard
$SCRIPTS/reload-extensions.sh $HOSTNAME

ssh "$HOSTNAME" sudo systemctl daemon-reload
ssh "$HOSTNAME" sudo systemctl start sysext-post-mount.service
