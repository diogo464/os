#!/usr/bin/env bash

BINARIES_DIR="$(dirname $0)/../binaries"

K3S_URL="https://github.com/k3s-io/k3s/releases/download/v1.28.4%2Bk3s2/k3s"
K3S_HASH="9014535a4cd20c788282d60398a06279983562093455b53ab76701539ce67acf"

ZSNAP_URL="https://git.d464.sh/infra/zsnap/releases/download/0.1.1/zsnap"
ZSNAP_HASH="0854e309278e47fe58a25e32b0c6ee43615a19eb496ea09f9c05250428f15aaa"

BLOCKY_URL="https://github.com/0xERR0R/blocky/releases/download/v0.23/blocky_v0.23_Linux_x86_64.tar.gz"
BLOCKY_HASH="ab02f58f2ae779c6323e130c2ac20cf6857b281c507821b80e7882908d02163b"

ACTRUNNER_URL="https://gitea.com/gitea/act_runner/releases/download/v0.2.6/act_runner-0.2.6-linux-amd64"
ACTRUNNER_HASH="234c2bdb871e7b0bfb84697f353395bfc7819faf9f0c0443845868b64a041057"

WGS_URL="https://git.d464.sh/code/wireguard-server/releases/download/0.2.0/wgs"
WGS_HASH="62b404188485c8b3417d0a0ce1fb4344852ab112e550810cc417b23705724c8c"

NODEEXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz"
NODEEXPORTER_HASH="0c9219b9860c6250c0bc3da5d79bd79c17f3938345fa7503f95cfa2ad7c3ba1d"

PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v2.54.0/prometheus-2.54.0.linux-amd64.tar.gz"
PROMETHEUS_HASH="67291f049367ab88bb7f39b9deb63915d60179329bfe5d01439eb4dca6a44ef0"

function fetch() {
	# arguments: name url hash
	local OUT="$BINARIES_DIR/$1"
	echo "Downloading $1 from $2"
	if [ -e "$OUT" ]; then
		echo "Binary already exists, skipping"
		return
	fi
	curl -L "$2" -o "$OUT" || exit 1
	echo "Checking $1's hash"
	local H=$(sha256sum "$OUT" | cut -d" " -f1)
	if [ "$H" != "$3" ]; then
		echo "Hash missmatch"
		echo "Expected	$3"
		echo "Found		$H"
		rm "$OUT"
		exit 1
	fi
	chmod +x "$OUT"
}

function fetch_targz() {
	# arguments: name url hash name_in_archive
	local OUT=$(realpath "$BINARIES_DIR/$1")
	local TDIR=$(mktemp -d)

	echo "Downloading $1 from $2"
	if [ -e "$OUT" ]; then
		echo "Binary already exists, skipping"
		return
	fi

	pushd $TDIR
		curl -L "$2" -o "$1.tar.gz" || exit 1
		tar -xf "$1.tar.gz" || exit 1
		find .
		mv $(find . -type f -name "$4") $OUT
	popd

	rm -rf $TDIR

	echo "Checking $1's hash"
	local H=$(sha256sum "$OUT" | cut -d" " -f1)
	if [ "$H" != "$3" ]; then
		echo "Hash missmatch"
		echo "Expected	$3"
		echo "Found		$H"
		rm "$OUT"
		exit 1
	fi
	chmod +x "$OUT"
}

mkdir -p "$BINARIES_DIR"
fetch k3s $K3S_URL $K3S_HASH
fetch zsnap $ZSNAP_URL $ZSNAP_HASH
fetch_targz blocky $BLOCKY_URL $BLOCKY_HASH blocky
fetch act_runner $ACTRUNNER_URL $ACTRUNNER_HASH
fetch wgs $WGS_URL $WGS_HASH
fetch_targz node_exporter $NODEEXPORTER_URL $NODEEXPORTER_HASH node_exporter
fetch_targz prometheus $PROMETHEUS_URL $PROMETHEUS_HASH prometheus

pushd router
	CGO_ENABLED=0 go build -o ../binaries/
popd
