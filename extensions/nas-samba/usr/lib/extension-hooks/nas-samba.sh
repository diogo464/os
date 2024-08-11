#!/usr/bin/env -S bash -x
cp /usr/etc/samba/smb.conf /etc/samba/smb.conf
systemctl restart smb
