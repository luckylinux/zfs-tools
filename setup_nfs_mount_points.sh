#!/bin/bash

# If toolpath not set, set it to current working directory
if [[ ! -v toolpath ]]
then
    toolpath=$(pwd)
fi

# Load configuration
source $toolpath/config.sh

# Define target
target="/export"

# Define array
mountpoints=( nextcloud syncthing seafile email aptcacherng git gitconfigbackup tools isos templates softwaredistribution fing nmap cache )

# Create $target folder if not exist
mkdir -p "${target}"

# For each element create folder & set -i attribute
for element in "${mountpoints[@]}"
do
:
    # Create mount point folder if not exist
    mkdir -p "${target}/${element}"

    # Set -i attribute, i.e. cannot remove/rename element & need to mount a filesystem in order to write to it
    chattr -i "${target}/${element}"
done
