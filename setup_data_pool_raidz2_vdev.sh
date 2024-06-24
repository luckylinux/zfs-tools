#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/load.sh

# Load modules
modprobe spl
modprobe zfs

# Create ZPOOL and add First 6-Disk RAIDZ2 VDEV
zpool create -f -o ashift=12 -O compression=lz4 -m none ${poolname} raidz2 "/dev/mapper/${luksdevices[0]}" "/dev/mapper/${luksdevices[1]}" "/dev/mapper/${luksdevices[2]}" "/dev/mapper/${luksdevices[3]}" "/dev/mapper/${luksdevices[4]}" "/dev/mapper/${luksdevices[5]}"

# Wait a bit
sleep 5

# Add Second 6-Disk RAIDZ2 VDEV
zpool add -o ashift=12 ${poolname} mirror "/dev/mapper/${luksdevices[6]}" "/dev/mapper/${luksdevices[7]}" "/dev/mapper/${luksdevices[8]}" "/dev/mapper/${luksdevices[9]}" "/dev/mapper/${luksdevices[10]}" "/dev/mapper/${luksdevices[11]}"
