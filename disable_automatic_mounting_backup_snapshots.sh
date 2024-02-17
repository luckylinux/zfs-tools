#!/bin/bash

# If toolpath not set, set it to current working directory
if [[ ! -v toolpath ]]
then
    toolpath=$(pwd)
fi

# Load configuration
source $toolpath/config.sh

# Get list of datasets
datasets=$(zfs list -H -o name | grep -i "zdata/BACKUP" | xargs -n1)

while IFS= read -r dataset; do
    # Mount it
    echo "Disable dataset $dataset"
    zfs set canmount=off $dataset
    zfs set mountpoint=none $dataset
    zfs set readonly=on $dataset
done <<< "$datasets"

