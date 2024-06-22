#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/config.sh

# Get list of datasets
datasets=$(zfs list -H -o name | grep -i "zdata/BACKUP" | xargs -n1)

while IFS= read -r dataset; do
    # Mount it
    echo "Disable dataset $dataset"
    zfs set canmount=off $dataset
    zfs set mountpoint=none $dataset
    zfs set readonly=on $dataset
done <<< "$datasets"

