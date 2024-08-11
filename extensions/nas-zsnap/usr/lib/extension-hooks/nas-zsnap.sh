#!/usr/bin/env -S bash -x

systemctl enable \
	zfs-scrub-monthly@borealis.timer \
	zfs-scrub-monthly@blackmesa.timer
systemctl restart zsnap
