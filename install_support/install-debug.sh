#!/bin/bash
# Install debug build.
# Author(s)
#   Jason R. McNeil - jasonrm - jason@jasonrm.net
localSource="./build/Debug/"

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (usually done via sudo)" 1>&2
   exit 1
fi

cp $localSource/zfs /usr/sbin/zfs
cp $localSource/zpool /usr/sbin/zpool
cp $localSource/libzfs.dylib /usr/lib/libzfs.dylib

rm -rf /System/Library/Filesystems/zfs.fs /Library/Extensions/zfs.kext

cp -R $localSource/zfs.fs /System/Library/Filesystems/zfs.fs
cp -R $localSource/zfs.kext /Library/Extensions/zfs.kext

chown -R root:wheel /Library/Extensions/zfs.kext
chown -R root:wheel /System/Library/Filesystems/zfs.fs
chown -R root:wheel /usr/sbin/zpool
chown -R root:wheel /usr/sbin/zfs
chown -R root:wheel /usr/lib/libzfs.dylib

rm -rf /System/Library/Caches/com.apple.kext.caches
touch /System/Library/Extensions
touch /Library/Extensions
