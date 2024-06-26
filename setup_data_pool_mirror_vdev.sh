#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/load.sh

# Load modules
modprobe spl
modprobe zfs

# Create ZPOOL and add first VDEV
zpool create -f -o ashift=${ashift} -O compression=lz4 -o compatibility=openzfs-2.0-linux -m none ${poolname} mirror "/dev/mapper/${luksdevices[0]}" "/dev/mapper/${luksdevices[1]}"

# Wait a bit
sleep 5

# Add second VDEV
zpool add -o ashift=${ashift} ${poolname} mirror "/dev/mapper/${luksdevices[2]}" "/dev/mapper/${luksdevices[3]}"

# Wait a bit
sleep 5

# Add third VDEV
#zpool add -o ashift=${ashift} ${poolname} mirror "/dev/mapper/${luksdevices[4]}" "/dev/mapper/${luksdevices[5]}"

# Wait a bit
#sleep 5

# Add fourth VDEV
#zpool add -o ashift=${ashift} ${poolname} mirror "/dev/mapper/${luksdevices[6]}" "/dev/mapper/${luksdevices[7]}"

# Wait a bit
#sleep 5

# Add fourth VDEV
#zpool add -o ashift=${ashift} ${poolname} mirror "/dev/mapper/${luksdevices[8]}" "/dev/mapper/${luksdevices[9]}"

# Wait a bit
#sleep 5

# Add fourth VDEV
#zpool add -o ashift=${ashift} ${poolname} mirror "/dev/mapper/${luksdevices[10]}" "/dev/mapper/${luksdevices[11]}"
