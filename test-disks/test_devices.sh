#!/bin/bash

# Determine toolpath if not set already
relativepath="../" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/config.sh

# Create folder
mkdir -p "${toolpath}/results/badblocks"

# For each device
for device in "${disks[@]}"
do
	# Display device informations
        parted /dev/disk/by-id/$device print

	# Prompt user for confirmation
        while true; do
                read -p "Run DESTRUCTIVE Badblocks on /dev/disk/by-id/$device ? [y / n] " answer
                case $answer in
                        [Yy]* ) break;;
                        [Nn]* ) exit;;
                        * ) echo "Please answer yes or no.";;
                esac
        done

	# Stop if there is a test already running
	smartctl -X /dev/disk/by-id/$device

	# Wait for operation to terminate
	#sleep 5

	# Run self-test
	#smartctl --test=long /dev/disk/by-id/$device

	# Show found errors
	#smartctl --attributes --log=selftest --quietmode=errorsonly /dev/disk/by-id/$device

	# Check for bad blocks
	#badblocks -wsv /dev/disk/by-id/$device -o "badblocks/${device}.log" & # With progress bar
	#badblocks -wv /dev/disk/by-id/$device -o "badblocks/${device}.log" & # Without progress bar
	#badblocks -b 4096 -wv /dev/disk/by-id/$device > "badblocks/${device}.log" & # Without progress bar
	#badblocks -b 512 -c 65536 -wv /dev/disk/by-id/$device > "badblocks/${device}.log" & # Without progress bar
	badblocks -b 4096 -c 65536 -wv -s /dev/disk/by-id/$device > "badblocks/${device}.log" & # Without progress bar
done
