#!/bin/bash
# ZFS test script using a ram disk...
# Author(s)
#   Jason R. McNeil - jasonrm - jason@jasonrm.net

diskSizeMB=256                      # in MB
diskSize=$(($diskSizeMB * 4 * 512)) # Number of sectors
poolName=testPool`date +%s`         # Should be a very unique pool name
bonnieTimes=0                       # Number of loops (zero to disable)
fsxTime=5                           # Minutes (zero to disable)

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (usually done via sudo)" 1>&2
   exit 1
fi


echo "==== Begin the setup process ===="
# Create a ramdisk
ramdisk=`hdiutil attach -nomount ram://$diskSize`
echo "Attached ramdisk of $diskSizeMB MB ($diskSize) to $ramdisk"

diskutil partitiondisk $ramdisk GPTFormat ZFS %noformat% 100%
while [ $? -ne 0 ]; do
    echo "Sometimes it doesn't work the first (or second, or Nth) time."
    diskutil partitiondisk $ramdisk GPTFormat ZFS %noformat% 100%
done

vdev="${ramdisk//[[:space:]]}s1"

zpool create $poolName $vdev
if [[ $? -ne 0 ]]; then
   echo "Very bad. The pool couldn't be created!?" 1>&2
   exit 1
fi

# Sometimes mdutil (spotlight) causes some issues.
mdutil -i off /Volumes/testPool

echo "==== Starting testing phase ===="
cd /Volumes/$poolName
echo " - Running fsx for $fsxTime minutes - "
fsx -h -c 1000 -v fsxTestFile -d $((fsxTime * 60))
echo " - Running bonnie $bonnieTimes times - "
counter=0
if [ $counter -lt $bonnieTimes ]
    then
        bonnie -s $(($diskSizeMB/2))
fi
echo "==== Finished testing phase ===="

echo "==== Destroy what we setup ===="
zpool destroy -f $poolName
counter=0
while [ $? -ne 0 ]; do
    echo "Sometimes it doesn't work the first (or second, or Nth) time."
    echo zpool destroy -f $poolName
    if [ $counter -gt 10 ]
        then
            echo "This means the script is has failed..."
            exit 1
    fi
done

# Detach the ramdisk
detached=`hdiutil detach $ramdisk`
echo "Detached ramdisk from $ramdisk"