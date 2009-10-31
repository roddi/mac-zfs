#!/bin/bash
# ZFS test script using a ram disk, fsx and/or bonnie
# 
# Notes:
#   - Requires fsx and bonnie to be in the path when enabled
#   - zpool created with only a single vdev, should be expanded to allow mirror/raidz1/etc
#
# Author(s)
#   Jason R. McNeil - jasonrm - jason@jasonrm.net
#
####################################################################################################
### Settings
diskSizeMB=256                      # zpool size in MB (roughly)
poolName=testPool`date +%s`         # Should be a very unique pool name

bonnieTimes=0                       # bonnie will do N loops (zero to disable)

fsxTime=60                          # fsx will run for N minutes (zero to disable)
fsxCloseOpen=100                    # fsx will close/open the test file every 1 out of N times
fsxLogRate=1000                     # fsx will print a log message every N commands
fsxTestFile=fsxtest`date +%s`       # fsx will use this as the base file name for test and log files
###
####################################################################################################

# Calculated Values
diskSize=$(($diskSizeMB * 4 * 512)) # Number of sectors

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
   echo "Usually very bad. The pool couldn't be created!?" 1>&2
   exit 1
fi

# Sometimes mdutil (spotlight) causes some issues.
mdutil -i off /Volumes/$poolName

echo "==== Starting testing phase ===="
cd /Volumes/$poolName
echo " - Running fsx for $fsxTime minutes - "
fsx -h -c $fsxCloseOpen -p $fsxLogRate $fsxTestFile -d $((fsxTime * 60))
echo " - Running bonnie $bonnieTimes times - "
counter=0
if [ $counter -lt $bonnieTimes ]
    then
        bonnie -s $(($diskSizeMB * 0.75))
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
            echo "This means the script has failed... not good."
            exit 1
    fi
done

# Detach the ramdisk
detached=`hdiutil detach $ramdisk`
echo "Detached ramdisk from $ramdisk"
echo
echo "==== Finished Test (does not imply success, check for errors) ===="
echo