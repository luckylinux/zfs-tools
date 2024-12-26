#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Pool name
pool=${1:-"zdata"}

# Load Configuration and Functions
source "${toolpath}/load.sh"

# Not needed anymore ?

# Unlock all volumes at once
# for disk in "${disks[@]}"
# do
# 
# done

# Unset variable in order to enhance security
unset ${password}
