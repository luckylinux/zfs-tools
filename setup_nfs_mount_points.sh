#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source "${toolpath}/load.sh"

# Define target
target="/export"

# Create $target folder if not exist
mkdir -p "${target}"

# For each element create folder & set -i attribute
for element in "${mountpoints[@]}"
do
    # Create mount point folder if not exist
    mkdir -p "${target}/${element}"

    # Set -i attribute, i.e. cannot remove/rename element & need to mount a filesystem in order to write to it
    chattr -i "${target}/${element}"
done
