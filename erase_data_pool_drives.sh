#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Load Configuration and Functions
source "${toolpath}/load.sh"

#

for device in "${disks[@]}"
do
       	# Display device informations
       	parted /dev/disk/by-id/$device print

	# Prompt user for confirmation
	while true; do
               	read -p "Erase all partitions on /dev/disk/by-id/$device ? [y / n] " answer
               	case $answer in
                       	[Yy]* ) break;;
              		[Nn]* ) exit;;
                      	* ) echo "Please answer yes or no.";;
               	esac
       	done

	# Create GPT label
	parted -s /dev/disk/by-id/$device mklabel GPT
done

# Clear password from memory
unset $password
unset $verify
