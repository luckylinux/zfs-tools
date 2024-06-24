#!/bin/bash

# Determine toolpath if not set already
relativepath="../" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/load.sh

# For each device
for device in "${disks[@]}"
do
    temp=$(smartctl -A /dev/disk/by-id/${device}  | egrep ^194 | awk '{print $10}')
    minmax=$(smartctl -A /dev/disk/by-id/${device}  | egrep ^194 | awk '{print $12}')

    echo "${device} -> ${temp}°C (Min/Max ${minmax}"
done
