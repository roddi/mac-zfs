#!/bin/bash
cd "`dirname $0`"

oldBuild=`cat ../../upstream/opensolaris/buildNumber`
newBuild=`curl -s http://dlc.sun.com/osol/on/downloads/current/ | grep -m 1 -Eo "b[[:digit:]]{3}"`

echo "Local  : ${oldBuild:1}"
echo "Server : ${newBuild:1}"

if [ "${oldBuild:1}" -ge "${newBuild:1}" ]
    then
        echo "There isn't a newer version available."
        exit 1
fi
echo "Updating to $newBuild"
cd ../..
curl -C - -o on-src.tar.bz2 http://dlc.sun.com/osol/on/downloads/current/on-src.tar.bz2
cd upstream/opensolaris
echo "Extracting, please wait..."
tar -v -x -T ../opensolaris-maczfs-manifest.txt -f ../../on-src.tar.bz2
echo -n "$newBuild" > buildNumber
echo "Done"
