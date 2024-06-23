#!/bin/bash

# Determine toolpath if not set already
relativepath="../" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/config.sh

# Create folder
mkdir -p "${toolpath}/results/smart"

# Generate Timestamp
timestamp=$(date +"%Y%m%d_%Hh%Mm%Ss")

# For each device
for device in "${disks[@]}"
do
        # Stop if there is a test already running
        smartctl -X /dev/disk/by-id/$device
done
