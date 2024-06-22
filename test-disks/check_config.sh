#!/bin/bash

# Determine toolpath if not set already
relativepath="../" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/config.sh

# Create folder
mkdir -p "${toolpath}/badblocks"

# Counter
counter=1

# For each device
for device in "${disks[@]}"
do
	if [ -h "/dev/disk/by-id/${device}" ]
	then
		echo "[$counter] Device /dev/disk/by-id/${device} exists"
	else
		echo "[$counter] ERROR: Device /dev/disk/by-id/${device} does not exist !"
	fi

	# Increase counter
	counter=$(($counter+1))
done
