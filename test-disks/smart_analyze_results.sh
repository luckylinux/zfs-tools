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
for device in "${disks[@]}"
do
        # Show all test results
        smartctl --attributes --log=selftest /dev/disk/by-id/${device} > ${toolpath}/results/smart/${device}_${timestamp}_all.log

        # Show found errors
        smartctl --attributes --log=selftest --quietmode=errorsonly /dev/disk/by-id/${device} > ${toolpath}/results/smart/${device}_${timestamp}_errors.log
done
