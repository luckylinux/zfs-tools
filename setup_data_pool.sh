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
zpool create -f -o ashift=12 -O compression=lz4 -m none zdata mirror "/dev/mapper/$encdevice01" "/dev/mapper/$encdevice02"

# Wait a bit
sleep 5

# Add second VDEV
zpool add -o ashift=12 zdata mirror "/dev/mapper/$encdevice03" "/dev/mapper/$encdevice04"

# Wait a bit
sleep 5

# Add third VDEV
#zpool add -o ashift=12 zdata mirror "/dev/mapper/$encdevice05" "/dev/mapper/$encdevice06"

# Wait a bit
#sleep 5

# Add fourth VDEV
#zpool add -o ashift=12 zdata mirror "/dev/mapper/$encdevice07" "/dev/mapper/$encdevice08"

# Wait a bit
#sleep 5

# Add fourth VDEV
#zpool add -o ashift=12 zdata mirror "/dev/mapper/$encdevice09" "/dev/mapper/$encdevice10"

# Wait a bit
#sleep 5

# Add fourth VDEV
#zpool add -o ashift=12 zdata mirror "/dev/mapper/$encdevice11" "/dev/mapper/$encdevice12"
