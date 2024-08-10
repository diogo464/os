#!/usr/bin/env bash
EXTENSIONS=$(dirname $0)/../extensions/
for d in $(ls -1 $EXTENSIONS); do
	mkdir -p $EXTENSIONS/$d/usr/lib/extension-release.d/
	echo "ID=_any" > $EXTENSIONS/$d/usr/lib/extension-release.d/extension-release.$d
done
