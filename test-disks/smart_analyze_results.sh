#!/bin/bash

# Determine toolpath if not set already
relativepath="../" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/load.sh

# Create folder
mkdir -p "${toolpath}/results/smart"

# Generate Timestamp
timestamp=$(date +"%Y%m%d_%Hh%Mm%Ss")

# For each device
for disk_config in "${disks[@]}"
do
    # Get Disk Path
    disk_name=$(get_disk_reference "${disk_config}")

    # Get Disk Partition Number
    partition_number=$(get_disk_partition_number "${disk_config}")

    # Get Device Mapper Name
    dm_name=$(get_device_mapper_name "${disk_config}")

    # Show all test results
    smartctl --attributes --log=selftest /dev/disk/by-id/${disk_name} > ${toolpath}/results/smart/${disk_name}_${timestamp}_all.log

    # Show found errors
    smartctl --attributes --log=selftest --quietmode=errorsonly /dev/disk/by-id/${disk_name} > ${toolpath}/results/smart/${disk_name}_${timestamp}_errors.log
done
