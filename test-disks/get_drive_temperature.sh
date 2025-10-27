#!/bin/bash

# Determine toolpath if not set already
relativepath="../" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/load.sh

# For each device
for disk_config in "${disks[@]}"
do
    # Get Disk Path
    disk_name=$(get_disk_reference "${disk_config}")

    # Get Disk Partition Number
    partition_number=$(get_disk_partition_number "${disk_config}")

    # Get Device Mapper Name
    dm_name=$(get_device_mapper_name "${disk_config}")

    # Get Temperatures
    temp=$(smartctl -A /dev/disk/by-id/${disk_name}  | egrep ^194 | awk '{print $10}')
    minmax=$(smartctl -A /dev/disk/by-id/${disk_name}  | egrep ^194 | awk '{print $12}')

    echo "/dev/disk/by-id/${disk_name} -> ${temp}°C (Min/Max ${minmax}"
done
