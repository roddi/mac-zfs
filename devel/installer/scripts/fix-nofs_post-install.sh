#!/bin/sh
echo "macZFS : post_install.sh"
macOSVersion=`system_profiler SPSoftwareDataType | grep "System Version" | grep -oE "[0-9]+\.[56]"`

if [ "$macOSVersion" == "10.6" ]; then
    sudo /usr/local/macZFS/fix-nofs
fi