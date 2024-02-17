#!/bin/bash

# If toolpath not set, set it to current working directory
if [[ ! -v toolpath ]]
then
    toolpath=$(pwd)
fi

# Load configuration
source $toolpath/config.sh

# Get list of datasets
datasets=$(zfs list -H -o name | xargs -n1)

while IFS= read -r dataset; do
    # Mount it
    echo "Mount dataset $dataset"
    zfs mount $dataset
done <<< "$datasets"
