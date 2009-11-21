#!/bin/sh
echo "macZFS : post-install.sh"

chown -R root:wheel /Library/Extensions/zfs.kext
chown -R root:wheel /System/Library/Filesystems/zfs.fs
chown -R root:wheel /usr/sbin/zpool
chown -R root:wheel /usr/sbin/zfs
chown -R root:wheel /usr/sbin/zoink
chown -R root:wheel /usr/lib/libzfs.dylib