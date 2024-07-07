#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Pool name
pool=${1:-"zdata"}

# Load Configuration
source "${toolpath}/load.sh"

# Get List of Datasets
datasets=$(zfs list -H -o name | xargs -n1 | grep -Ei "^${pool}")

while IFS= read -r dataset; do
    # Echo
    echo "Mount dataset ${dataset}"

    # Mount Dataset
    zfs mount ${dataset}
done <<< "${datasets}"
