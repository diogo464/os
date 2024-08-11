#!/usr/bin/env -S bash -x

systemctl daemon-reload
cd /usr/lib/extension-hooks || exit 0
for script in $(ls -1); do
	./$script
done
