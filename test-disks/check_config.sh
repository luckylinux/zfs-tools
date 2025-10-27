#!/bin/bash

# Determine toolpath if not set already
relativepath="../" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/load.sh

# Create folder
mkdir -p "${toolpath}/badblocks"

# Counter
counter=1

# For each device
for disk-config in "${disks[@]}"
do
    # Get Disk Path
    disk_name=$(get_disk_reference "${disk_config}")

    # Get Disk Partition Number
    partition_number=$(get_disk_partition_number "${disk_config}")

    # Get Device Mapper Name
    dm_name=$(get_device_mapper_name "${disk_config}")

    if [ -h "/dev/disk/by-id/${disk_name}" ]
    then
        echo "[$counter] Device /dev/disk/by-id/${disk_name} exists"
    else
        echo "[$counter] ERROR: Device /dev/disk/by-id/${disk_name} does not exist !"
    fi

    # Increase counter
    counter=$(($counter+1))
done
